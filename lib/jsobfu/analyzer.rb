require_relative 'ecma_tight'
require 'set'

class JSObfu::Analyzer < JSObfu::ECMANoWhitespaceVisitor

  attr_reader :external_refs
  attr_reader :scope

  def initialize
    @scope = JSObfu::Scope.new
    @external_refs  = Set.new
  end

  # Maintains a stack of closures that we have visited. This method is called
  # everytime we visit a nested function.
  #
  # Javascript is functionally-scoped, so a function(){} creates its own
  # unique closure. When resolving variables, Javascript looks "up" the
  # closure stack, ending up as a property lookup in the global scope
  # (available as `window` in all browsers)
  #
  # This is changed in newer ES versions, where a `let` keyword has been
  # introduced, which has regular C-style block scoping. We'll ignore this
  # feature since it is not yet widely used.
  def visit_SourceElementsNode(o)
    scope.push!

    hoister = JSObfu::Hoister.new(parent_scope: scope)
    o.value.each { |x| hoister.accept(x) }

    hoister.scope.keys.each do |key|
      scope.rename_var(key)
    end

    ret = super

    scope.pop!
    
    hoister.scope_declaration + ret
  end

  # Called whenever a variable is referred to (not declared).
  #
  # If the variable was never added to scope, it is assumed to be a global
  # object (like "document"), and hence will not be obfuscated.
  #
  def visit_ResolveNode(o)
    new_val = scope.rename_var(o.value, :generate => false)
    unless new_val
      @external_refs << o.value
    end

    super
  end

  # Called when a parameter is declared. "Shadowed" parameters in the original
  # source are preserved - the randomized name is "shadowed" from the outer scope.
  def visit_ParameterNode(o)
    o.value = JSObfu::Utils::random_var_encoding(scope.rename_var(o.value))

    super
  end

  # Called whenever a variable is declared.
  def visit_VarDeclNode(o)
    o.name = JSObfu::Utils::random_var_encoding(scope.rename_var(o.name))

    super
  end


end

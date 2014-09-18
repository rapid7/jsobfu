require_relative 'ecma_tight'

class JSObfu::Obfuscator < JSObfu::ECMANoWhitespaceVisitor

  # @return [JSObfu::Scope] the scope maintained while walking the ast
  attr_reader :scope

  # Note: At a high level #renames is not that useful, because var shadowing can
  # cause multiple variables in different contexts to be mapped separately.
  # - joev

  # @return [Hash] of original var/fn names to our new random neames
  attr_reader :renames

  # @param opts [Hash] the options hash
  # @option opts [JSObfu::Scope] :scope the optional scope to save vars to
  def initialize(opts={})
    @scope = opts.fetch(:scope, JSObfu::Scope.new)
    @renames = {}
    super()
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
    if scope.top?
      analysis = JSObfu::Analyzer.new
      # analysis.accept(o.dup)
      # analysis.external_refs.each {|ref| scope.renames[ref] = nil}
    end

    scope.push!

    hoister = JSObfu::Hoister.new(parent_scope: scope)
    o.value.each { |x| hoister.accept(x) }

    hoister.scope.keys.each do |key|
      rename_var(key)
    end

    ret = super

    scope.pop!
    
    hoister.scope_declaration + ret
  end

  def visit_FunctionDeclNode(o)
    o.value = if o.value and o.value.length > 0
      JSObfu::Utils::random_var_encoding(scope.rename_var(o.value))
    else
      if rand(3) != 0
        JSObfu::Utils::random_var_encoding(scope.random_var_name)
      end
    end

    super
  end

  def visit_FunctionExprNode(o)
    if o.value != 'function'
      o.value = JSObfu::Utils::random_var_encoding(rename_var(o.value))
    end

    super
  end

  # Called whenever a variable is declared.
  def visit_VarDeclNode(o)
    o.name = JSObfu::Utils::random_var_encoding(rename_var(o.name))

    super
  end

  # Called whenever a variable is referred to (not declared).
  #
  # If the variable was never added to scope, it is assumed to be a global
  # object (like "document"), and hence will not be obfuscated.
  #
  def visit_ResolveNode(o)
    new_val = rename_var(o.value, :generate => false)
    o.value = JSObfu::Utils::random_var_encoding(new_val || o.value)

    # Never use external referance as a random var rename
    if o.value == ''
      puts "EXTERNAL RENAME #{o.value}" unless new_val
    end

    unless new_val
      # scope.add_external(o.value)
    end

    super
  end

  # Called when a parameter is declared. "Shadowed" parameters in the original
  # source are preserved - the randomized name is "shadowed" from the outer scope.
  def visit_ParameterNode(o)
    o.value = JSObfu::Utils::random_var_encoding(rename_var(o.value))

    super
  end

  # A property node in an object, like {a:1, b:2, "\x55":333} etc
  def visit_PropertyNode(o)
    # if it is a non-alphanumeric property, obfuscate the string's bytes
    if o.name =~ /^[a-zA-Z_][a-zA-Z0-9_]*$/
       o.instance_variable_set :@name, '"'+JSObfu::Utils::random_string_encoding(o.name)+'"'
    end

    super
  end

  def visit_NumberNode(o)
    o.value = JSObfu::Utils::transform_number(o.value)
    super
  end

  def visit_StringNode(o)
    o.value = JSObfu::Utils::transform_string(o.value, scope)
    super
  end

  protected

  # Assigns the var {var_name} a new obfuscated name
  def rename_var(var_name, opts={})
    @renames[var_name] = scope.rename_var(var_name, opts)
  end

end

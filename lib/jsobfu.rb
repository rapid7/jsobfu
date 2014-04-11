require 'rkelly'

class RKelly::Nodes::Node
  attr_accessor :obfuscated
end

# The primary class, used to parse and obfuscate Javascript code.
class JSObfu

  require_relative 'jsobfu/scope'
  require_relative 'jsobfu/utils'
  require_relative 'jsobfu/minifier'

  # @return [JSObfu::Scope] the global scope
  attr_reader :scope

  #
  # Saves +code+ for later obfuscation with #obfuscate
  #
  def initialize(code)
    @code = code
    @scope = Scope.new
  end

  #
  # Add +str+ to the un-obfuscated code.
  # Calling this method after #obfuscate is undefined
  #
  def <<(str)
    @code << str
  end

  def to_s
    @code
  end

  # @return [RKelly::Nodes::SourceElementsNode] the abstract syntax tree
  def ast
    parse unless @ast
    @ast
  end

  # Parse and obfuscate
  #
  # @param opts [Hash] the options hash
  # @option opts [Boolean] :strip_whitespace allow whitespace in the output code
  #
  # @return [String] if successful
  def obfuscate(opts={})
    @code = JSObfu::Minifier.new.accept(ast).to_s
    if opts.fetch(:strip_whitespace, true)
      @code.gsub!(/(^\s+|\s+$)/, '')
      @code.delete!("\n")
      @code.delete!("\r")
    end
    self
  end

protected

  #
  # Generate an Abstract Syntax Tree (#ast) for later obfuscation
  #
  def parse
    parser = RKelly::Parser.new
    @ast = parser.parse(@code)
  end

  #
  # Recursive method to obfuscate the given +ast+.
  #
  # +ast+ should be the result of RKelly::Parser#parse
  #
  def obfuscate_r(as)
    JSObfu::Visitor.new
    # ast.each do |node|
    #   if node and @debug
    #     dputs(node.class.to_s)
    #     dputs(node.to_ecma.to_s[0..100].split("\n").first)
    #   end

    #   case node
    #   when RKelly::Nodes::SourceElementsNode
    #     scope.push!

    #   #when RKelly::Nodes::ObjectLiteralNode

    #   when RKelly::Nodes::PropertyNode
    #     # Property names must be bare words or string literals NOT
    #     # expressions!  Can't use transform_string() here
    #     if node.name =~ /^[a-zA-Z_][a-zA-Z0-9_]*$/
    #       n = '"'
    #       node.name.unpack("C*") { |c|
    #         n << case rand(3)
    #         when 0; "\\x%02x"%(c)
    #         when 1; "\\#{c.to_s 8}"
    #         when 2; [c].pack("C")
    #         end
    #       }
    #       n << '"'
    #       node.instance_variable_set :@name, n
    #     end

    #   # Variables
    #   when RKelly::Nodes::VarDeclNode
    #     node.name = scope.rename_var(node.name)

    #   when RKelly::Nodes::ParameterNode
    #     node.value = scope.rename_var(node.value)

    #   when RKelly::Nodes::ResolveNode
    #     new_var = scope.rename_var(node.value, :generate => false)
    #     node.value = new_var unless new_var.nil?

    #   when RKelly::Nodes::DotAccessorNode
    #     dputs "\t"+node.value.class.to_s
    #     case node.value
    #     when RKelly::Nodes::ResolveNode
    #       # new_var = scope.rename_var(node.value.value, :generate => false)
    #       # node.value.value = new_var unless new_var.nil?
    #     end

    #   when RKelly::Nodes::FunctionDeclNode
    #     unless node.obfuscated
    #       node.value = scope.rename_var(node.value)
    #       node.obfuscated = true
    #     end

    #   when RKelly::Nodes::NumberNode
    #     node.value = transform_number(node.value)

    #   when RKelly::Nodes::StringNode
    #     node.value = transform_string(node.value)
    #   end
    # end

    nil
  end
end

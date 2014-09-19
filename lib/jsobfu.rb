require 'rkelly'

# The primary class, used to parse and obfuscate Javascript code.
class JSObfu

  require_relative 'jsobfu/scope'
  require_relative 'jsobfu/utils'
  require_relative 'jsobfu/ecma_tight'
  require_relative 'jsobfu/hoister'
  require_relative 'jsobfu/analyzer'
  require_relative 'jsobfu/obfuscator'
  require_relative 'jsobfu/encoder'

  # @return [JSObfu::Scope] the global scope
  attr_reader :scope

  # Saves +code+ for later obfuscation with #obfuscate
  def initialize(code)
    @code = code
    @scope = Scope.new
  end

  # Add +str+ to the un-obfuscated code.
  # Calling this method after #obfuscate is undefined
  def <<(str)
    @code << str
  end

  # @return [String] the (possibly obfuscated) code
  def to_s
    @code
  end

  # @return [RKelly::Nodes::SourceElementsNode] the abstract syntax tree
  def ast
    @ast || parse
  end

  # Parse and obfuscate
  #
  # @param opts [Hash] the options hash
  # @option opts [Boolean] :strip_whitespace allow whitespace in the output code
  #
  # @return [String] if successful
  def obfuscate(opts={})
    @obfuscator = JSObfu::Obfuscator.new(scope: @scope)
    @code = @obfuscator.accept(ast).to_s
    if opts.fetch(:strip_whitespace, true)
      @code.gsub!(/(^\s+|\s+$)/, '')
      @code.delete!("\n")
      @code.delete!("\r")
    end
    self
  end

  # Returns the obfuscated name for the variable or function +sym+
  #
  # @param [String] sym the name of the variable or function 
  # @return [String] the obfuscated name
  def sym(sym)
    raise RuntimeError, "Must obfuscate before calling #sym" if @obfuscator.nil?
    @obfuscator.renames[sym.to_s]
  end

protected

  #
  # Generate an Abstract Syntax Tree (#ast) for later obfuscation
  #
  def parse
    parser = RKelly::Parser.new
    @ast = parser.parse(@code)
  end

end

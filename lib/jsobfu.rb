require 'rkelly'

#
# The primary class, used to parse and obfuscate Javascript code.
#
class JSObfu

  require_relative 'jsobfu/scope'
  require_relative 'jsobfu/utils'
  require_relative 'jsobfu/ecma_tight'
  require_relative 'jsobfu/hoister'
  require_relative 'jsobfu/obfuscator'
  require_relative 'jsobfu/disable'

  include JSObfu::Disable

  # @return [JSObfu::Scope] the global scope
  attr_reader :scope

  # Saves +code+ for later obfuscation with #obfuscate
  # @param code [#to_s] the code to obfuscate
  def initialize(code)
    @code = code.to_s
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
  # @option opts [Boolean] :strip_whitespace removes unnecessary whitespace from
  #   the output code (true)
  # @option opts [Integer] :iterations number of times to run the
  #   obfuscator on this code (1)
  # @return [self]
  def obfuscate(opts={})
    return self if JSObfu.disabled?

    iterations = opts.fetch(:iterations, 1).to_i
    strip_whitespace = opts.fetch(:strip_whitespace, true)

    iterations.times do |i|
      obfuscator = JSObfu::Obfuscator.new(scope: @scope)
      @code = obfuscator.accept(ast).to_s
      if strip_whitespace
        @code.gsub!(/(^\s+|\s+$)/, '')
        @code.delete!("\n")
        @code.delete!("\r")
      end

      new_renames = obfuscator.renames.dup
      if @renames
        # "patch up" the renames after each iteration
        @renames.each do |key, prev_rename|
          @renames[key] = new_renames[prev_rename]
        end
      else
        # on first iteration, take the renames as-is
        @renames = new_renames
      end

      unless i == iterations-1
        @scope = Scope.new
        @ast = nil # force a re-parse
      end
    end

    self
  end

  # Returns the obfuscated name for the variable or function +sym+
  #
  # @param sym [String] the name of the variable or function
  # @return [String] the obfuscated name
  def sym(sym)
    return sym.to_s if @renames.nil?
    @renames[sym.to_s]
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

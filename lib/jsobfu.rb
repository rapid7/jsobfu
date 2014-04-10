require 'rkelly'

# The primary class, used to parse and obfuscate Javascript code.
class JSObfu

  require_relative 'jsobfu/scope'
  require_relative 'jsobfu/utils'

  # @return [JSObfu::Scope] the global scope
  attr_reader :scope

  #
  # The maximum length of a string that can be passed through
  # #transform_string without being chopped up into separate
  # expressions and concatenated
  #
  MAX_STRING_CHUNK = 10000

  #
  # Saves +code+ for later obfuscation with #obfuscate
  #
  def initialize(code)
    @code = code
    @funcs = {}
    @vars  = {}
    @scope = Scope.new
  end

  #
  # Add +str+ to the un-obfuscated code.
  # Calling this method after #obfuscate is undefined
  #
  def <<(str)
    @code << str
  end

  #
  # Return the (possibly obfuscated) code as a string.
  #
  # If #obfuscate has not been called before this, returns the parsed,
  # unobfuscated code.  This can be useful for example to remove comments and
  # standardize spacing.
  #
  # @param opts [Hash] the options hash
  # @option opts [Boolean] :strip_whitespace allow whitespace in the output code
  #
  # @return [String] the minimized, obfuscated code
  #
  def to_s(opts={})
    strip_whitespace = opts.fetch(:strip_whitespace, true)
    code = ast.to_ecma

    if strip_whitespace
      code.gsub!(/(^\s+|\s+$)/, '')
      code.delete!("\n")
      code.delete!("\r")
    end

    code
  end

  # You MUST call #obfuscate before this method!
  # @return [String] the obfuscated name of a symbol
  def sym(lookup)
    @vars[lookup] || @funcs[lookup] || lookup
  end

  # @return [RKelly::Nodes::SourceElementsNode] the abstract syntax tree
  def ast
    parse unless @ast
    @ast
  end

  # Parse and obfuscate
  # @return [self] if successful
  def obfuscate
    parse
    obfuscate_r
    self
  end

protected

  #
  # Recursive method to obfuscate the given +ast+.
  #
  # +ast+ should be the result of RKelly::Parser#parse
  #
  def obfuscate_r(ast=self.ast)
    scope.push!

    ast.each do |node|
      case node
      when nil
        nil

      when ::RKelly::Nodes::SourceElementsNode
        # Recurse
        obfuscate_r(node.value)

      #when ::RKelly::Nodes::ObjectLiteralNode
        # TODO
        #$stdout.puts(node.methods - Object.new.methods)
        #$stdout.puts(node.value.inspect)

      when ::RKelly::Nodes::PropertyNode
        # Property names must be bare words or string literals NOT
        # expressions!  Can't use transform_string() here
        if node.name =~ /^[a-zA-Z_][a-zA-Z0-9_]*$/
          n = '"'
          node.name.unpack("C*") { |c|
            case rand(3)
            when 0; n << "\\x%02x"%(c)
            when 1; n << "\\#{c.to_s 8}"
            when 2; n << [c].pack("C")
            end
          }
          n << '"'
          node.instance_variable_set :@name, n
        end

      # Variables
      when ::RKelly::Nodes::VarDeclNode
        node.name = scope.rename_var(node.name)
      when ::RKelly::Nodes::ParameterNode
        node.value = scope.rename_var(node.value)
      when ::RKelly::Nodes::ResolveNode
        #$stdout.puts("Resolve bodyOnload: #{@vars[node.value]}") if "bodyOnLoad" == node.value
        # node.value = scope.rename_var(node.value) if scope.has_key?(node.value)
      when ::RKelly::Nodes::DotAccessorNode
        case node.value
        when ::RKelly::Nodes::ResolveNode
          node.value.value = scope.rename_var(node.value.value)
        #else
        # $stderr.puts("Non-resolve node as target of dotaccessor: #{node.value.class}")
        end

      # Functions
      when ::RKelly::Nodes::FunctionDeclNode
        #$stdout.puts("FunctionDecl: #{node.value}")
        # Functions can also act as objects, so store them in the vars
        # and the functions list so we can replace them in both places
        node.value = scope.rename_var(node.value)
      when ::RKelly::Nodes::FunctionCallNode
        # The value of a FunctionCallNode is some sort of accessor node or a ResolveNode
        # so this is basically useless
        #$stdout.puts("Function call: #{node.name} => #{@funcs[node.name]}")
        #node.value = @funcs[node.value] if @funcs[node.value]

      # Transformers
      when ::RKelly::Nodes::NumberNode
        node.value = transform_number(node.value)
      when ::RKelly::Nodes::StringNode
        node.value = transform_string(node.value)
      else
        #$stderr.puts "#{node.class}: #{node.value}"
        #$stderr.puts "#{node.class}"
      end

      #unless node.kind_of? ::RKelly::Nodes::SourceElementsNode
      # $stderr.puts "#{node.class}: #{node.value}"
      #end
    end

    scope.pop!
    nil
  end

  #
  # Generate an Abstract Syntax Tree (#ast) for later obfuscation
  #
  def parse
    parser = RKelly::Parser.new
    @ast = parser.parse(@code)
  end

  #
  # Convert a number to a random base (decimal, octal, or hexedecimal).
  #
  # Given 10 as input, the possible return values are:
  #   "10"
  #   "0xa"
  #   "012"
  #
  # @param num [Integer] number to convert to random base
  # @return [String] equivalent encoding in a different base
  #
  def rand_base(num)
    case rand(3)
    when 0; num.to_s
    when 1; "0%o" % num
    when 2; "0x%x" % num
    end
  end

  #
  # Return a mathematical expression that will evaluate to the given number
  # +num+.
  #
  # +num+ can be a float or an int, but should never be negative.
  #
  def transform_number(num)
    case num
    when Fixnum
      if num == 0
        r = rand(10) + 1
        transformed = "('#{JSObfu::Utils.rand_text_alpha(r)}'.length - #{r})"
      elsif num > 0 and num < 10
        # use a random string.length for small numbers
        transformed = "'#{JSObfu::Utils.rand_text_alpha(num)}'.length"
      else
        transformed = "("
        divisor = rand(num) + 1
        a = num / divisor.to_i
        b = num - (a * divisor)
        # recurse half the time for a
        a = (rand(2) == 0) ? transform_number(a) : rand_base(a)
        # recurse half the time for divisor
        divisor = (rand(2) == 0) ? transform_number(divisor) : rand_base(divisor)
        transformed << "#{a}*#{divisor}"
        transformed << "+#{b}"
        transformed << ")"
      end
    when Float
      transformed = "(#{num - num.floor} + #{rand_base(num.floor)})"
    end

    transformed
  end

  #
  # Convert a javascript string into something that will generate that string.
  #
  # Randomly calls one of the +transform_string_*+ methods
  #
  def transform_string(str)
    quote = str[0,1]
    # pull off the quotes
    str = str[1,str.length - 2]
    return quote*2 if str.length == 0

    if str.length > MAX_STRING_CHUNK
      return safe_split(str, quote, false).map { |args| transform_string(args[1]) }.join('+')
    end

    case rand(2)
    when 0
      transform_string_split_concat(str, quote)
    when 1
      transform_string_fromCharCode(str)
    end
  end

  #
  # Split a javascript string, +str+, without breaking escape sequences.
  #
  # The maximum length of each piece of the string is half the total length
  # of the string, ensuring we (almost) always split into at least two
  # pieces.  This won't always be true when given a string like "AA\x41",
  # where escape sequences artificially increase the total length (escape
  # sequences are considered a single character).
  #
  # Returns an array of two-element arrays.  The zeroeth element is a
  # randomly generated variable name, the first is a piece of the string
  # contained in +quote+s.
  #
  # See #escape_length
  #
  # @param str [String] the String to split
  # @param quote [String] the quote ("|')
  # @return [Array] 2d array series of [[var_name, string], ...]
  #
  def safe_split(str, quote, assign_vars=true)
    parts = []
    max_len = str.length / 2
    while str.length > 0
      len = 0
      loop do
        e_len = escape_length(str[len..-1])
        e_len = 1 if e_len.nil?
        len += e_len
        # if we've reached the end of the string, bail
        break unless str[len]
        break if len > max_len
        # randomize the length of each part
        break if (rand(max_len) == 0)
      end

      part = str.slice!(0, len)

      var = assign_vars ? scope.random_var_name : nil
      parts.push( [ var, "#{quote}#{part}#{quote}" ] )
    end

    parts
  end

  #
  # Stolen from obfuscatejs.rb
  # Determines the length of an escape sequence
  #
  # @param str [String] the String to check the length on
  # @return [Integer] the length of the character at the head of the string
  #
  def escape_length(str)
    esc_len = nil
    if str[0,1] == "\\"
      case str[1,1]
      when "u"; esc_len = 6     # unicode \u1234
      when "x"; esc_len = 4     # hex, \x41
      when /[0-7]/              # octal, \123, \0
        str[1,3] =~ /([0-7]{1,3})/
        if $1.to_i(8) > 255
          str[1,3] =~ /([0-7]{1,2})/
        end
        esc_len = 1 + $1.length
      else; esc_len = 2         # \" \n, etc.
      end
    end
    esc_len
  end

  #
  # Split a javascript string, +str+, into multiple randomly-ordered parts
  # and return an anonymous javascript function that joins them in the
  # correct order.  This method can be called safely on strings containing
  # escape sequences.  See #safe_split.
  #
  
  #
  def transform_string_split_concat(str, quote)
    parts = safe_split(str, quote)
    func = "(function () { var "
    ret = "; return "
    parts.sort { |a,b| rand }.each do |part|
      func << "#{part[0]}=#{part[1]},"
    end
    func.chop!

    ret  << parts.map{|part| part[0]}.join("+")
    final = func + ret + " })()"

    final
  end

  #
  # Return a call to String.fromCharCode() with each char of the input as arguments
  #
  # Example:
  #   input : "A\n"
  #   output: String.fromCharCode(0x41, 10)
  #
  # @param str [String] the String to transform (with no quotes)
  # @return [String] Javascript code that evaluates to #str
  #
  def transform_string_fromCharCode(str)
    "String.fromCharCode(#{string_to_bytes(str)})"
  end

  #
  # Converts a string to a series of byte values
  #
  # @param str [String] the Javascript string to encode (no quotes)
  # @return [String] containing a comma-separated list of byte values
  # with random encodings (decimal/hex/octal)
  #
  def string_to_bytes(str)
    len = 0
    bytes = str.unpack("C*")
    encoded_bytes = []

    while str.length > 0
      if str[0,1] == "\\"
        str.slice!(0,1)
        # then this is an escape sequence and we need to deal with all
        # the special cases
        case str[0,1]
        # For chars that contain their non-escaped selves, step past
        # the backslash and let the rand_base() below decide how to
        # represent the character.
        when '"', "'", "\\", " "
          char = str.slice!(0,1).unpack("C").first
        # For symbolic escapes, use the known value
        when "n"; char = 0x0a; str.slice!(0,1)
        when "t"; char = 0x09; str.slice!(0,1)
        # Lastly, if it's a hex, unicode, or octal escape, pull out the
        # real value and use that
        when "x"
          # Strip the x
          str.slice!(0,1)
          char = str.slice!(0,2).to_i 16
        when "u"
          # This can potentially lose information in the case of
          # characters like \u0041, but since regular ascii is stored
          # as unicode internally, String.fromCharCode(0x41) will be
          # represented as 00 41 in memory anyway, so it shouldn't
          # matter.
          str.slice!(0,1)
          char = str.slice!(0,4).to_i 16
        when /[0-7]/
          # Octals are a bit harder since they are variable width and
          # don't necessarily mean what you might think. For example,
          # "\61" == "1" and "\610" == "10".  610 is a valid octal
          # number, but not a valid ascii character.  Javascript will
          # interpreter as much as it can as a char and use the rest
          # as a literal.  Boo.
          str =~ /([0-7]{1,3})/
          char = $1.to_i 8
          if char > 255
            str =~ /([0-7]{1,2})/
            char = $1.to_i 8
          end
          str.slice!(0, $1.length)
        end
      else
        char = str.slice!(0,1).unpack("C").first
      end
      encoded_bytes << rand_base(char) if char
    end

    encoded_bytes.join(',')
  end
end

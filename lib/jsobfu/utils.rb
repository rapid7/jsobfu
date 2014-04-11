# Some quick utility functions to minimize dependencies

module JSObfu::Utils

  #
  # The maximum length of a string that can be passed through
  # #transform_string without being chopped up into separate
  # expressions and concatenated
  #
  MAX_STRING_CHUNK = 10000

  ALPHA_CHARSET = ([*'A'..'Z']+[*'a'..'z']).freeze
  ALPHANUMERIC_CHARSET = (ALPHA_CHARSET+[*'0'..'9']).freeze

  # Returns a random alphanumeric string of the desired length
  # @param [Integer] len the desired length
  # @return [String] random a-zA-Z0-9 text
  def self.rand_text_alphanumeric(len)
    rand_text(ALPHANUMERIC_CHARSET, len)
  end

  # Returns a random alpha string of the desired length
  # @param [Integer] len the desired length
  # @return [String] random a-zA-Z text
  def self.rand_text_alpha(len)
    rand_text(ALPHA_CHARSET, len)
  end

  # Returns a random string of the desired length in the desired charset
  # @param [Array] charset the available chars
  # @param [Integer] len the desired length
  # @return [String] random text
  def self.rand_text(charset, len)
    len.times.map { charset.sample }.join
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
  def self.rand_base(num)
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
  def self.transform_number(num)
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
  def self.transform_string(str, scope)
    str = str.dup
    quote = str[0,1]
    # pull off the quotes
    str = str[1,str.length - 2]
    return quote*2 if str.length == 0

    if str.length > MAX_STRING_CHUNK
      return safe_split(str, :quote => quote).map { |arg| transform_string(arg, scope) }.join('+')
    end

    case rand(2)
    when 0
      transform_string_split_concat(str, quote, scope)
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
  # @param opts [Hash] the options hash
  # @options opts [String]  :quote the quoting character ("|')
  #
  # @return [Array] 2d array series of [[var_name, string], ...]
  #
  def self.safe_split(str, opts={})
    quote = opts.fetch(:quote)

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

      parts.push("#{quote}#{part}#{quote}")
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
  def self.escape_length(str)
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
  def self.transform_string_split_concat(str, quote, scope)
    parts = safe_split(str, :quote => quote).map {|s| [scope.random_var_name, s] }
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
  def self.transform_string_fromCharCode(str)
    "String.fromCharCode(#{string_to_bytes(str)})"
  end

  #
  # Converts a string to a series of byte values
  #
  # @param str [String] the Javascript string to encode (no quotes)
  # @return [String] containing a comma-separated list of byte values
  # with random encodings (decimal/hex/octal)
  #
  def self.string_to_bytes(str)
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

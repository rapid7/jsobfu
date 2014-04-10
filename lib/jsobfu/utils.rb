# Some quick utility functions to minimize dependencies

module JSObfu::Utils

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

end

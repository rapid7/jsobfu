require 'spec_helper'

describe JSObfu::Utils do
  # the number of iterations while testing randomness
  let(:n) { 50 }

  describe '#rand_text_alphanumeric' do
    let(:len) { 15 }

    # generates a new random string on every call
    def output; JSObfu::Utils.rand_text_alphanumeric(len); end

    it 'returns strings of length 15' do
      expect(n.times.map { output }.join.length).to be(n*len)
    end

    it 'returns strings in alpha charset' do
      expect(n.times.map { output }.join).to be_in_charset(described_class::ALPHANUMERIC_CHARSET)
    end
  end

  describe '#rand_text_alpha' do
    let(:len) { 15 }
    
    # generates a new random string on every call
    def output; JSObfu::Utils.rand_text_alpha(len); end

    it 'returns strings of length 15' do
      expect(n.times.map { output }.join.length).to be(n*len)
    end

    it 'returns strings in alpha charset' do
      expect(n.times.map { output }.join).to be_in_charset(described_class::ALPHA_CHARSET)
    end
  end

  describe '#rand_text' do    
    let(:len) { 5 }
    let(:charset) { described_class::ALPHA_CHARSET }

    # generates a new random string on every call
    def output; JSObfu::Utils.rand_text(charset, len); end

    it 'returns strings of length 15' do
      expect(n.times.map { output }.join.length).to be(n*len)
    end

    it 'returns strings in the specified charset' do
      expect(n.times.map { output }.join).to be_in_charset(charset)
    end
  end
end

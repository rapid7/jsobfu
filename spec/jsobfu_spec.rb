require 'spec_helper'

describe JSObfu do

  subject(:jsobfu) do
    described_class.new("")
  end

  # surround the string in quotes
  def quote(str, q='"'); "#{q}#{str}#{q}" end

  describe '#transform_string' do
    context 'when given a string of length > MAX_STRING_CHUNK' do
      let(:js_string) { quote "ABC"*described_class::MAX_STRING_CHUNK }

      it 'calls itself recursively' do
        expect(jsobfu).to receive(:transform_string).at_least(2).times.and_call_original
        jsobfu.send(:transform_string, js_string.dup)
      end
    end

    context 'when given a string of length < MAX_STRING_CHUNK' do
      let(:js_string) { quote "A"*(described_class::MAX_STRING_CHUNK/2).to_i }

      it 'does not call itself recursively' do
        expect(jsobfu).to receive(:transform_string).once.and_call_original
        jsobfu.send(:transform_string, js_string.dup)
      end
    end
  end

  describe '#safe_split' do
    let(:js_string) { "\\x66\\x67"*600 }
    let(:quote)     { '"' }
    let(:parts) { 50.times.map { jsobfu.send(:safe_split, js_string.dup, quote).map{ |a| a[1] } } }

    describe 'quoting' do
      context 'when given a double-quote' do
        let(:quote) { '"' }
        it 'surrounds all the split strings with the same quote' do
          expect(parts.flatten.all? { |part| part.start_with?(quote) }).to be_true
        end
      end

      context 'when given a single-quote' do
        let(:quote) { "'" }
        it 'surrounds all the split strings with the same quote' do
          expect(parts.flatten.all? { |part| part.start_with?(quote) }).to be_true
        end
      end
    end

    describe 'splitting' do
      context 'when given a hex-escaped series of bytes' do
        let(:js_string) { "\\x66\\x67"*600 }

        it 'never splits in the middle of a hex escape' do
          expect(parts.flatten.all? { |part| part.start_with?('"\\') }).to be_true
        end
      end

      context 'when given a unicode-escaped series of bytes' do
        let(:js_string) { "\\u0066\\u0067"*600 }

        it 'never splits in the middle of a unicode escape' do
          expect(parts.flatten.all? { |part| part.start_with?('"\\') }).to be_true
        end
      end
    end
  end

end

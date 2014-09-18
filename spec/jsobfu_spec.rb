require 'spec_helper'

describe JSObfu do

  TEST_STRING = 'var x; function y() {};'

  subject(:jsobfu) do
    instance = described_class.new(TEST_STRING)
    instance.obfuscate
    instance
  end

  describe '#sym' do
    context 'when given the string "x"' do
      it 'returns some string' do
        expect(jsobfu.sym('x')).not_to be_nil
      end
    end

    context 'when given the string "YOLOSWAG"' do
      it 'returns nil' do
        expect(jsobfu.sym('x')).to be_nil
      end
    end
  end

end

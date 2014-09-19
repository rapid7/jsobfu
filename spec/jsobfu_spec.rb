require 'spec_helper'

describe JSObfu do

  TEST_STRING = 'var x; function y() {};'

  subject(:jsobfu) do
    described_class.new(TEST_STRING)
  end

  let(:iterations) { 1 }

  before do
    jsobfu.obfuscate(iterations: iterations)
  end

  describe '#sym' do
    context 'when given the string "x"' do
      it 'returns some string' do
        expect(jsobfu.sym('x')).not_to be_nil
      end
    end

    context 'when given the string "YOLOSWAG"' do
      it 'returns nil' do
        expect(jsobfu.sym('YOLOSWAG')).to be_nil
      end
    end

    context 'when iterations: 2 is passed to obfuscate()' do
      let(:iterations) { 2 }

      context 'when given the string "x"' do
        it 'returns some string' do
          expect(jsobfu.sym('x')).not_to be_nil
        end
      end

      context 'when given the string "YOLOSWAG"' do
        it 'returns nil' do
          expect(jsobfu.sym('YOLOSWAG')).to be_nil
        end
      end
    end
  end

end

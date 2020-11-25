require_relative 'spec_helper'

describe CalendariumRomanum::Enum do
  let(:enum_values) { [:a, :b] }

  let(:test_class) do
    d = described_class
    Class.new do
      extend d
      values { [:a, :b] }
    end
  end

  describe '.all' do
    it 'returns all values in the original order' do
      expect(test_class.all).to eq enum_values
    end
  end

  describe '.each' do
    it 'yields all values in the original order' do
      expect {|b| test_class.each(&b) }.to yield_successive_args(*enum_values)
    end
  end

  describe '[]' do
    describe 'default indexing' do
      it 'finds first element' do
        expect(test_class[0]).to be :a
      end

      it 'finds last element' do
        expect(test_class[1]).to be :b
      end

      it 'returns nil for index out of range' do
        expect(test_class[2]).to be nil
      end
    end

    describe 'indexed by a custom property' do
      let(:test_class) do
        d = described_class
        Class.new do
          extend d
          values(index_by: :to_s) { [1] }
        end
      end

      it 'finds the element' do
        expect(test_class['1']).to eq 1
      end

      it 'returns nil for an unknown index' do
        expect(test_class[1]).to be nil
      end
    end
  end
end

require 'spec_helper'

# expectations concerning the Ruby implementation
describe Date do
  describe '#-' do
    it 'returns Rational' do
      date_diff = Date.new(2013,5,5) - Date.new(2013,5,1)
      expect(date_diff).to be_a Rational
      expect(date_diff.numerator).to eq 4
    end
  end

  describe 'range' do
    let(:range) { (Date.new(2000,1,1) .. Date.new(2010,1,1)) }

    # please note that the RSpec 'include' matcher cannot
    # be used here, because it does't simply test
    # if `n.include?(x)` returns true (see it's implementation)
    # and it yields misleading results when testing inclusion
    # of DateTime in a Date range.
    describe 'test Date inclusion' do
      it 'includes' do
        expect(range.include?(Date.new(2005,3,3))).to be true
      end

      it 'excludes' do
        expect(range.include?(Date.new(1995,3,3))).to be false
      end
    end

    describe 'test DateTime inclusion' do
      # DateTime without time details is treated just like Date
      describe 'without time specified' do
        it 'excludes' do
          expect(range.include?(DateTime.new(1995,3,3))).to be false
        end

        it 'includes' do
          expect(range.include?(DateTime.new(2005,3,3))).to be true
        end
      end

      # treatment of a DateTime with time details is different
      describe 'with time specified' do
        it 'excludes a DateTime not falling in the range' do
          expect(range.include?(DateTime.new(1995,3,3,1,1,1))).to be false
        end

        it '... but also one *falling* in the range!' do
          expect(range.include?(DateTime.new(2005,3,3,1,1,1))).to be false
        end
      end
    end
  end

  describe 'inheritance' do
    it 'is inherited by DateTime' do
      expect(DateTime.new).to be_a Date
    end
  end
end

require_relative 'spec_helper'

describe CR::Util::Year do
  let(:y) { described_class.new 2000 }
  let(:day_count) { 366 }

  describe '#each' do
    it 'yields for each iteration' do
      expect {|b| y.each(&b) }.to yield_control
    end

    it 'yields the expected number of times' do
      expect {|b| y.each(&b) }.to yield_control.exactly(day_count).times
    end

    it 'yields calendar day instances' do
      expected_class = Array.new(day_count, Date)
      expect {|b| y.each(&b) }.to yield_successive_args(*expected_class)
    end

    it 'returns Enumerator if called without a block' do
      expect(y.each).to be_a Enumerator
    end
  end
end

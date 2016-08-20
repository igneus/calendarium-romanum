require_relative 'spec_helper'

describe Rank do
  describe 'comparison' do
    it 'memorial x ferial' do
      expect(MEMORIAL_GENERAL).to be > FERIAL
    end
  end

  describe '[]' do
    it 'has all existing instances indexed by rank number' do
      expect(Ranks[1.1]).to eq Ranks::TRIDUUM
    end
  end

  describe '#<' do
    it { expect(Ranks[1.2]).to be < Ranks[1.1] }
    it { expect(Ranks[1.1]).not_to be < Ranks[1.2] }
  end

  describe '#>' do
    it { expect(Ranks[1.1]).to be > Ranks[1.2] }
    it { expect(Ranks[1.2]).not_to be > Ranks[1.1] }
  end

  describe '#==' do
    it { expect(Ranks[1.2]).to be == Ranks[1.2] }
    it { expect(Ranks[1.2]).not_to be == Ranks[1.1] }
  end
end

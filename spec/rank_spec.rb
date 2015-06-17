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
end

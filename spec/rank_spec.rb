require_relative 'spec_helper'

describe Rank do
  describe 'comparison' do
    it 'memorial x ferial' do
      expect(MEMORIAL_GENERAL).to be > FERIAL
    end
  end
end
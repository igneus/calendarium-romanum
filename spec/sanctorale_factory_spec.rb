# coding: utf-8
require 'spec_helper'

describe CR::SanctoraleFactory do
  describe '.create_layered'

  describe '.load_layered_from_files' do
    before :each do
      files = %w(czech-cs.txt czech-cechy-cs.txt czech-budejovice-cs.txt).collect do |f|
        File.join(File.expand_path('../data', File.dirname(__FILE__)), f)
      end
      @s = described_class.load_layered_from_files(*files)
    end

    it 'has celebrations from the first file' do
      dd = @s.get 9, 28
      expect(dd.size).to eq 1

      d = dd.first
      expect(d.rank).to eq CR::Ranks::SOLEMNITY_PROPER
      expect(d.title).to eq 'Sv. Václava, mučedníka, hlavního patrona českého národa'
    end

    it 'has celebrations from the second file' do
      dd = @s.get 7, 4
      expect(dd.size).to eq 1

      d = dd.first
      expect(d.rank).to eq CR::Ranks::MEMORIAL_PROPER
      expect(d.title).to eq 'Sv. Prokopa, opata'
    end

    it 'celebrations from the last file win' do
      dd = @s.get 12, 22
      expect(dd.size).to eq 1

      d = dd.first
      expect(d.rank).to eq CR::Ranks::FEAST_PROPER
      expect(d.title).to eq 'Výročí posvěcení katedrály sv. Mikuláše'
    end
  end
end

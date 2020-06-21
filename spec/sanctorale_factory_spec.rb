# coding: utf-8
require 'spec_helper'

describe CR::SanctoraleFactory do
  describe '.create_layered'

  describe '.load_layered_from_files' do
    let(:s) do
      files = %w(czech-cs.txt czech-cechy-cs.txt czech-budejovice-cs.txt).collect do |f|
        File.join(File.expand_path('../data', File.dirname(__FILE__)), f)
      end

      described_class.load_layered_from_files(*files)
    end

    it 'has celebrations from the first file' do
      dd = s.get 9, 28
      expect(dd.size).to eq 1

      d = dd.first
      expect(d.rank).to eq CR::Ranks::SOLEMNITY_PROPER
      expect(d.title).to eq 'Sv. Václava, mučedníka, hlavního patrona českého národa'
    end

    it 'has celebrations from the second file' do
      dd = s.get 7, 4
      expect(dd.size).to eq 1

      d = dd.first
      expect(d.rank).to eq CR::Ranks::MEMORIAL_PROPER
      expect(d.title).to eq 'Sv. Prokopa, opata'
    end

    it 'celebrations from the last file win' do
      dd = s.get 12, 22
      expect(dd.size).to eq 1

      d = dd.first
      expect(d.rank).to eq CR::Ranks::FEAST_PROPER
      expect(d.title).to eq 'Výročí posvěcení katedrály sv. Mikuláše'
    end

    it 'creates merged metadata' do
      merged = {
        'title' => 'kalendář českobudějovické diecéze',
        'description' => 'Calendar for diocese of České Budějovice, Czech Republic',
        'locale' => 'cs',
        'country' => 'cz',
        'diocese' => 'České Budějovice',
      }
      expect(merged).to be < s.metadata
      expect(s.metadata).not_to have_key 'extends'
    end

    it 'stores original metadata' do
      components = [
        {
          'title' => 'Český národní kalendář',
          'description' => 'Calendar for the dioceses of Czech Republic',
          'locale' => 'cs',
          'country' => 'cz',
        },
        {
          'title' => 'kalendář české církevní provincie',
          'description' => 'Calendar for province of Bohemia',
          'locale' => 'cs',
          'country' => 'cz',
          'province' => 'Bohemia',
          'extends' => ['czech-cs.txt'],
        },
        {
          'title' => 'kalendář českobudějovické diecéze',
          'description' => 'Calendar for diocese of České Budějovice, Czech Republic',
          'locale' => 'cs',
          'country' => 'cz',
          'diocese' => 'České Budějovice',
          'extends' => ['czech-cs.txt', 'czech-cechy-cs.txt'],
        },
      ]
      expect(s.metadata['components'])
        .to eq(components)
    end
  end
end

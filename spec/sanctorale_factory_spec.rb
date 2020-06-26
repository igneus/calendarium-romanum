# coding: utf-8
require 'spec_helper'

# checking for Hash subset using the `<` operator is really handy here, but not available
# on Ruby < 2.3.0 and we still want to support Ruby 2.0. => 'backports' gem to the rescue
require 'backports/2.3.0/hash/lt'

describe CR::SanctoraleFactory do
  describe '.create_layered' do
    describe 'metadata handling' do
      let(:metadata_a) { {'title' => 'Calendar', 'foo' => 'bar'} }
      let(:metadata_b) { {'title' => 'Second calendar', 'some' => 'handsome', 'extends' => ['with_a']} }
      let(:metadata_nonhash) { [:something] }
      let(:with_a) { CR::Sanctorale.new.tap {|s| s.metadata = metadata_a }}
      let(:with_b) { CR::Sanctorale.new.tap {|s| s.metadata = metadata_b } }
      let(:without) { CR::Sanctorale.new }
      let(:with_nonhash) { CR::Sanctorale.new.tap {|s| s.metadata = metadata_nonhash } }

      it 'creates merged metadata' do
        merged = {
          # conflicting key - later wins
          'title' => 'Second calendar',
          # non-conflicting key from the first
          'foo' => 'bar',
          # non-conflicting key from the second
          'some' => 'handsome',
        }

        result = described_class.create_layered(with_a, with_b)

        expect(merged).to be < result.metadata

        # key 'extends' has special meaning and is therefore
        # always deleted from merged metadata
        expect(result.metadata).not_to have_key 'extends'
      end

      it 'stores original metadata' do
        result = described_class.create_layered(with_a, with_b)
        expect(result.metadata['components'])
          .to eq [metadata_a, metadata_b]
      end

      it 'overwrites key "components" if it exists' do
        result = described_class.create_layered(
          with_a,
          # this calendar's metadata have key 'components',
          # but that key is special and we always set it's contents
          # when merging
          CR::Sanctorale.new.tap {|s| s.metadata = {'components' => :c} }
        )
        expect(result.metadata['components'])
          .to eq [metadata_a, {'components' => :c}]
      end

      it 'copes with nil metadata on the first place' do
        result = described_class.create_layered(without, with_a)

        expect(metadata_a).to be < result.metadata
        expect(result.metadata['components'])
          .to eq [nil, metadata_a] # nils are preserved in 'components'
      end

      it 'copes with nil metadata on the last place' do
        result = described_class.create_layered(with_a, without)

        expect(metadata_a).to be < result.metadata
        expect(result.metadata['components'])
          .to eq [metadata_a, nil]
      end

      it 'copes with all nil' do
        result = described_class.create_layered(without, without)

        expect(result.metadata['components'])
          .to eq [nil, nil]
      end

      it 'copes with non-Hash metadata' do
        result = described_class.create_layered(
          with_a,
          with_nonhash
        )
        # non-Hash metadata are not merged, but they do appear
        # in 'components'
        expect(metadata_a).to be < result.metadata
        expect(result.metadata['components'])
          .to eq [metadata_a, metadata_nonhash]
      end

      it 'copes with all non-Hash' do
        result = described_class.create_layered(with_nonhash)

        expect(result.metadata['components'])
          .to eq [metadata_nonhash]
      end
    end
  end

  shared_examples 'calendar layering České Budějovice' do
    it 'has celebrations from the first file' do
      dd = layered_sanctorale.get 9, 28
      expect(dd.size).to eq 1

      d = dd.first
      expect(d.rank).to eq CR::Ranks::SOLEMNITY_PROPER
      expect(d.title).to eq 'Sv. Václava, mučedníka, hlavního patrona českého národa'
    end

    it 'has celebrations from the second file' do
      dd = layered_sanctorale.get 7, 4
      expect(dd.size).to eq 1

      d = dd.first
      expect(d.rank).to eq CR::Ranks::MEMORIAL_PROPER
      expect(d.title).to eq 'Sv. Prokopa, opata'
    end

    it 'celebrations from the last file win' do
      dd = layered_sanctorale.get 12, 22
      expect(dd.size).to eq 1

      d = dd.first
      expect(d.rank).to eq CR::Ranks::FEAST_PROPER
      expect(d.title).to eq 'Výročí posvěcení katedrály sv. Mikuláše'
    end
  end

  describe '.load_layered_from_files' do
    let(:layered_sanctorale) do
      files = %w(czech-cs.txt czech-cechy-cs.txt czech-budejovice-cs.txt).collect do |f|
        File.join(File.expand_path('../data', File.dirname(__FILE__)), f)
      end

      described_class.load_layered_from_files(*files)
    end

    include_examples 'calendar layering České Budějovice'
  end

  describe '.load_with_parents' do
    let(:layered_sanctorale) do
      path = File.join(File.expand_path('../data', File.dirname(__FILE__)), 'czech-budejovice-cs.txt')

      described_class.load_with_parents path
    end

    include_examples 'calendar layering České Budějovice'
  end
end

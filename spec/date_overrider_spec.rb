require_relative 'spec_helper'

describe CR::DateOverrider do
  let(:subject) { described_class.new overrides }

  let(:year) { 2000 }
  let(:temporale) { CR::Temporale.new year }
  let(:sanctorale) { CR::Sanctorale.new }

  let(:nullus) { CR::Celebration.new('S. Nullius', CR::Ranks::MEMORIAL_OPTIONAL, CR::Colours::WHITE, :nullus) }
  let(:ignotus) { CR::Celebration.new('S. Ignoti', CR::Ranks::MEMORIAL_OPTIONAL, CR::Colours::WHITE, :ignotus) }

  describe 'no overrides' do
    let(:overrides) { {} }

    it 'returns arguments unchanged' do
      result = subject.call temporale, sanctorale

      expect(result[0]).to be temporale
      expect(result[1]).to be sanctorale
    end
  end

  describe 'overrides for unknown celebrations' do
    # the overridden celebration is not known to either temporale or sanctorale
    let(:overrides) { {Date.new(year - 10, 7, 5) => :nullus} }

    it 'returns arguments unchanged' do
      result = subject.call temporale, sanctorale

      expect(result[0]).to be temporale
      expect(result[1]).to be sanctorale
    end
  end

  describe 'no overrides for the given year' do
    let(:overrides) { {Date.new(1990, 7, 5) => :nullus} }

    it 'returns arguments unchanged' do
      sanctorale.add 1, 14, nullus

      result = subject.call temporale, sanctorale

      expect(result[0]).to be temporale
      expect(result[1]).to be sanctorale
    end
  end

  describe 'sanctorale celebration overridden' do
    let(:overrides) { {Date.new(year + 1, 7, 5) => :nullus} }

    it 'returns sanctorale with the override applied' do
      pending 'waits for reasonable date moving support in Sanctorale'

      sanctorale.add 1, 14, nullus

      new_temporale, new_sanctorale = subject.call temporale, sanctorale

      expect(new_sanctorale).to be_a CR::Sanctorale
      expect(new_sanctorale).not_to be sanctorale
      expect(new_sanctorale.get(7, 5)).to eq [nullus]
      expect(new_sanctorale.get(1, 17)).to eq []

      expect(new_temporale).to be temporale
    end
  end

  describe 'temporale celebration overridden' do
    let(:overrides) { {Date.new(year + 1, 7, 5) => :corpus_christi} }

    it 'returns temporale with the override applied' do
      new_temporale, new_sanctorale = subject.call temporale, sanctorale

      expect(new_temporale).to be_a CR::Temporale
      expect(new_temporale).not_to be temporale
      expect(new_temporale[Date.new(2001, 7, 5)]).to eq CR::Temporale::CelebrationFactory.corpus_christi
      expect(new_temporale[CR::Temporale::Dates.corpus_christi(year)]).to be_ferial

      expect(new_sanctorale).to be sanctorale
    end
  end
end

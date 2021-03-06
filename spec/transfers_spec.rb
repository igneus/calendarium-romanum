require_relative 'spec_helper'

describe CR::Transfers do
  let(:transfers) { described_class.new temporale, sanctorale }
  let(:temporale) { double(CR::Temporale) }
  let(:sanctorale) { double(CR::Sanctorale) }

  # Temporale year properties:
  # not really important for the specs, important is just that they make sense together
  let(:year) { 2000 }
  let(:date_range) { CR::Temporale::Dates.first_advent_sunday(2000) .. (CR::Temporale::Dates.first_advent_sunday(2001) - 1) }

  # example celebrations
  let(:ferial) { CR::Celebration.new(rank: CR::Ranks::FERIAL) }
  let(:primary) { CR::Celebration.new(rank: CR::Ranks::PRIMARY) }
  let(:solemnity) { CR::Celebration.new(rank: CR::Ranks::SOLEMNITY_GENERAL) }

  before :each do
    allow(temporale).to receive_messages(year: year, date_range: date_range)
  end

  def date_set(date, temporale_cel: nil, sanctorale_cel: nil)
    allow(temporale)
      .to receive(:[]).with(date).and_return(temporale_cel || ferial)
    allow(sanctorale)
      .to receive(:[]).with(date).and_return(sanctorale_cel ? [sanctorale_cel] : [])
  end

  def date_set_free(date)
    date_set(date)
  end

  def date_set_temporale_impeded(date)
    date_set(date, temporale_cel: primary)
  end

  describe 'no-operation scenarios' do
    it 'no sanctorale solemnities' do
      allow(sanctorale).to receive(:solemnities).and_return({})

      expect(transfers.call).to eq({})
    end

    it 'solemnity collides with a non-solemnity' do
      date = Date.new(2001, 5, 5)
      allow(sanctorale)
        .to receive(:solemnities).and_return({CR::AbstractDate.from_date(date) => solemnity})
      allow(temporale)
        .to receive(:[]).with(date).and_return(ferial)

      expect(transfers.call).to eq({})
    end
  end

  describe 'logic of finding the target date' do
    let(:date) { Date.new(2001, 5, 5) }

    before :each do
      allow(sanctorale)
        .to receive(:solemnities).and_return({CR::AbstractDate.from_date(date) => solemnity})

      date_set(date, temporale_cel: primary, sanctorale_cel: solemnity)
    end

    it 'transfers to the following day if free' do
      date_set_free(date + 1)

      expect(transfers.call).to eq({(date + 1) => solemnity})
    end

    it 'transfers to the preceding day if free and the following day is not' do
      date_set_temporale_impeded(date + 1)
      date_set_free(date - 1)

      expect(transfers.call).to eq({(date - 1) => solemnity})
    end

    it 'transfers to the second following day if necessary' do
      date_set_temporale_impeded(date + 1)
      date_set_temporale_impeded(date - 1)
      date_set_free(date + 2)

      expect(transfers.call).to eq({(date + 2) => solemnity})
    end

    it 'transfers to the second preceding day if necessary' do
      date_set_temporale_impeded(date + 1)
      date_set_temporale_impeded(date + 2)
      date_set_temporale_impeded(date - 1)
      date_set_free(date - 2)

      expect(transfers.call).to eq({(date - 2) => solemnity})
    end
  end

  describe 'logic of which of conflicting solemnities is transferred' do
    let(:date) { Date.new(2001, 5, 5) }

    let(:higher_solemnity) { CR::Celebration.new(rank: CR::Ranks::SOLEMNITY_GENERAL) }
    let(:lower_solemnity) { CR::Celebration.new(rank: CR::Ranks::SOLEMNITY_PROPER) }

    before :each do
      allow(sanctorale)
        .to receive(:solemnities).and_return({CR::AbstractDate.from_date(date) => sanctorale_solemnity})
      date_set(date, temporale_cel: temporale_solemnity, sanctorale_cel: sanctorale_solemnity)

      date_set_free(date + 1)
    end

    describe 'higher rank in temporale' do
      let(:temporale_solemnity) { higher_solemnity }
      let(:sanctorale_solemnity) { lower_solemnity }

      it 'wins' do
        expect(transfers.call).to eq({date => temporale_solemnity, (date + 1) => sanctorale_solemnity})
      end
    end

    describe 'higher rank in sanctorale' do
      let(:temporale_solemnity) { lower_solemnity }
      let(:sanctorale_solemnity) { higher_solemnity }

      it 'wins' do
        expect(transfers.call).to eq({date => sanctorale_solemnity, (date + 1) => temporale_solemnity})
      end
    end

    describe 'equal ranks' do
      let(:temporale_solemnity) { CR::Celebration.new('t', rank: CR::Ranks::SOLEMNITY_GENERAL) }
      let(:sanctorale_solemnity) { CR::Celebration.new('s', rank: CR::Ranks::SOLEMNITY_GENERAL) }

      it 'temporale wins' do
        expect(transfers.call).to eq({date => temporale_solemnity, (date + 1) => sanctorale_solemnity})
      end
    end
  end

  describe 'impeding and non-impeding ranks' do
    (CR::Ranks::FEAST_PROPER .. CR::Ranks::TRIDUUM).each do |rank|
      it "does not transfer solemnity to a day with celebration of rank #{rank.desc.inspect}" do
        solemnity = CR::Celebration.new(rank: CR::Ranks::SOLEMNITY_PROPER)
        solemnities = {CR::AbstractDate.new(5, 5) => solemnity}
        allow(sanctorale).to receive(:solemnities).and_return(solemnities)

        date = Date.new(2001, 5, 5)

        celebration_in_the_way = CR::Celebration.new(rank: rank)

        date_set(date, temporale_cel: primary, sanctorale_cel: solemnity)
        date_set(date + 1, sanctorale_cel: celebration_in_the_way)
        date_set_free(date - 1)

        # date+1 was impeded by celebration_in_the_way, transferring backwards
        expect(transfers.call).to eq({(date - 1) => solemnity})
      end
    end

    (CR::Ranks::FERIAL .. CR::Ranks::FERIAL_PRIVILEGED).each do |rank|
      it "does transfer solemnity to a day with celebration of rank #{rank.desc.inspect}" do
        solemnity = CR::Celebration.new(rank: CR::Ranks::SOLEMNITY_PROPER)
        solemnities = {CR::AbstractDate.new(5, 5) => solemnity}
        allow(sanctorale).to receive(:solemnities).and_return(solemnities)

        date = Date.new(2001, 5, 5)

        celebration_in_the_way = CR::Celebration.new(rank: rank)

        date_set(date, temporale_cel: primary, sanctorale_cel: solemnity)
        date_set(date + 1, sanctorale_cel: celebration_in_the_way)
        date_set_free(date - 1)

        # celebration_in_the_way smashed, solemnity takes it's place
        expect(transfers.call).to eq({(date + 1) => solemnity})
      end
    end
  end

  describe 'transferring multiple solemnities' do
    let(:a) { CR::Celebration.new(rank: CR::Ranks::SOLEMNITY_PROPER) }
    let(:b) { CR::Celebration.new(rank: CR::Ranks::SOLEMNITY_GENERAL) }

    let(:date_a) { Date.new(2001, 5, 5) }
    let(:date_b) { Date.new(2001, 5, 6) }

    before :each do
      solemnities = {CR::AbstractDate.new(5, 5) => a, CR::AbstractDate.new(5, 6) => b}
      allow(sanctorale).to receive(:solemnities).and_return(solemnities)
    end

    it 'one back, one forward' do
      date_set(date_a, temporale_cel: primary, sanctorale_cel: a)
      date_set(date_b, temporale_cel: primary, sanctorale_cel: b)
      date_set_free(date_b + 1)
      date_set_free(date_a - 1)

      expect(transfers.call).to eq({(date_a - 1) => a, (date_b + 1) => b})
    end

    it 'both forward' do
      date_set(date_a, temporale_cel: primary, sanctorale_cel: a)
      date_set(date_b, temporale_cel: primary, sanctorale_cel: b)
      date_set_temporale_impeded(date_a - 1)
      date_set_temporale_impeded(date_a - 2)
      date_set_free(date_b + 1)
      date_set_free(date_b + 2)

      expect(transfers.call).to eq({(date_b + 1) => a, (date_b + 2) => b})
    end
  end

  describe 'sanctorale solemnity in the blind spot around first Advent Sunday' do
    # liturgical year with two instances of November 30th
    let(:year) { 1999 }
    let(:date_range) { CR::Temporale::Dates.first_advent_sunday(1999) .. (CR::Temporale::Dates.first_advent_sunday(2001) - 1) }

    it 'throws an exception' do
      allow(sanctorale)
        .to receive(:solemnities).and_return({CR::AbstractDate.new(11, 30) => solemnity})
      allow(temporale)
        .to receive(:[]).and_return ferial

      expect { transfers.call }
        .to raise_exception RuntimeError, /twice in liturgical year/
    end
  end

  describe 'special cases' do
    # see special rule in "Normae universales" 60
    it 'Annunciation occurring with the Holy week' do
      date = CR::Temporale::Dates.palm_sunday(year) + 1

      solemnity = CR::Celebration.new(rank: CR::Ranks::SOLEMNITY_PROPER, symbol: :annunciation)
      solemnities = {CR::AbstractDate.from_date(date) => solemnity}
      allow(sanctorale).to receive(:solemnities).and_return(solemnities)

      date_set(date, temporale_cel: primary, sanctorale_cel: solemnity)
      destination = CR::Temporale::Dates.easter_sunday(year) + 8
      date_set_free(destination)

      allow(temporale).to receive(:palm_sunday).and_return(CR::Temporale::Dates.palm_sunday(year))
      allow(temporale).to receive(:easter_sunday).and_return(CR::Temporale::Dates.easter_sunday(year))

      # closest free days are before Palm Sunday, but liturgical law explicitly requires
      # transfer to days after Easter Octave
      expect(transfers.call).to eq({destination => solemnity})
    end
  end
end

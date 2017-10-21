# coding: utf-8
require_relative 'spec_helper'

describe CR::Temporale do
  before :all do
    @t = @t12 = described_class.new 2012
    @t13 = described_class.new 2013
  end

  describe '.liturgical_year' do
    it 'returns liturgical year for the given date' do
      [
        [Date.new(2014, 11, 1), 2013],
        [Date.new(2014, 12, 1), 2014]
      ].each do |date, year|
        expect(described_class.liturgical_year(date)).to eq year
      end
    end
  end

  describe '#first_advent_sunday determines first Sunday of Advent' do
    [
      [2004, [11, 28]],
      [2010, [11, 28]],
      [2011, [11, 27]],
      [2012, [12, 2]],
      [2013, [12, 1]]
    ].each do |d|
      year, date = d
      it year do
        temporale = described_class.new(year)
        expect(temporale.first_advent_sunday).to eq Date.new(year, *date)
      end
    end
  end

  describe '#easter_sunday determines Easter Sunday' do
    [
      [2003, [2004, 4, 11]],
      [2004, [2005, 3, 27]],
      [2005, [2006, 4, 16]],
      [2006, [2007, 4, 8]],
      [2014, [2015, 4, 5]]
    ].each do |d|
      year, date = d
      it year do
        temporale = described_class.new(year)
        expect(temporale.easter_sunday).to eq Date.new(*date)
      end
    end
  end

  describe '#date_range' do
    it 'includes days of the year' do
      expect(@t.date_range).to include Date.new(2012, 12, 3)
      expect(@t.date_range).to include Date.new(2013, 11, 5)
    end
  end

  describe '#season' do
    it 'determines Advent' do
      expect(@t13.season(Date.new(2013, 12, 1))).to eq CR::Seasons::ADVENT
      expect(@t13.season(Date.new(2013, 12, 24))).to eq CR::Seasons::ADVENT
    end

    it 'determines Christmas' do
      expect(@t13.season(Date.new(2013, 12, 25))).to eq CR::Seasons::CHRISTMAS
      expect(@t13.season(Date.new(2014, 1, 12))).to eq CR::Seasons::CHRISTMAS
      expect(@t13.season(Date.new(2014, 1, 13))).to eq CR::Seasons::ORDINARY
    end

    it 'determines Lent' do
      expect(@t13.season(Date.new(2014, 3, 4))).to eq CR::Seasons::ORDINARY
      expect(@t13.season(Date.new(2014, 3, 5))).to eq CR::Seasons::LENT
      expect(@t13.season(Date.new(2014, 4, 19))).to eq CR::Seasons::LENT
      expect(@t13.season(Date.new(2014, 4, 20))).to eq CR::Seasons::EASTER
    end

    it 'determines Easter time' do
      expect(@t13.season(Date.new(2014, 4, 20))).to eq CR::Seasons::EASTER
      expect(@t13.season(Date.new(2014, 6, 8))).to eq CR::Seasons::EASTER
      expect(@t13.season(Date.new(2014, 6, 9))).to eq CR::Seasons::ORDINARY
    end
  end

  describe '#season_beginning' do
    let(:year) { 2016 }
    let(:options) { {} }
    let(:t) { described_class.new(year, **options) }

    describe 'unsupported season' do
      it 'fails' do
        season = CR::Season.new(:strawberry_season, CR::Colours::RED)
        expect do
          t.season_beginning season
        end.to raise_exception(ArgumentError, /unsupported season/)
      end
    end

    describe 'Ordinary Time' do
      describe 'Epiphany not transferred' do
        it do
          expect(t.season_beginning(CR::Seasons::ORDINARY))
            .to eq Date.new(2017, 1, 9)
        end
      end

      describe 'Epiphany transferred' do
        let(:t) { described_class.new(year, transfer_to_sunday: [:epiphany]) }

        it do
          expect(t.season_beginning(CR::Seasons::ORDINARY))
            .to eq Date.new(2017, 1, 10)
        end
      end
    end
  end

  describe '#get' do
    it 'returns a Celebration' do
      expect(@t13.get(8, 12)).to be_a CR::Celebration
    end

    describe 'for' do
      describe 'ferial' do
        it 'in Ordinary Time' do
          c = @t13.get(8, 12)
          expect(c.rank).to eq CR::Ranks::FERIAL
          expect(c.color).to eq CR::Colours::GREEN
        end

        it 'in Advent' do
          c = @t13.get(12, 12)
          expect(c.rank).to eq CR::Ranks::FERIAL
          expect(c.color).to eq CR::Colours::VIOLET
        end

        it 'in the last week of Advent' do
          c = @t13.get(12, 23)
          expect(c.rank).to eq CR::Ranks::FERIAL_PRIVILEGED
          expect(c.color).to eq CR::Colours::VIOLET
        end

        it 'in Christmas time' do
          c = @t13.get(1, 3)
          expect(c.rank).to eq CR::Ranks::FERIAL
          expect(c.color).to eq CR::Colours::WHITE
        end

        it 'in Lent' do
          c = @t13.get(3, 18)
          expect(c.rank).to eq CR::Ranks::FERIAL_PRIVILEGED
          expect(c.color).to eq CR::Colours::VIOLET
        end

        it 'in Easter Time' do
          c = @t13.get(5, 5)
          expect(c.rank).to eq CR::Ranks::FERIAL
          expect(c.color).to eq CR::Colours::WHITE
        end
      end

      describe 'Sunday' do
        it 'in Ordinary Time' do
          c = @t13.get(8, 10)
          expect(c.rank).to eq CR::Ranks::SUNDAY_UNPRIVILEGED
          expect(c.color).to eq CR::Colours::GREEN
        end

        it 'in Advent' do
          c = @t13.get(12, 15)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.color).to eq CR::Colours::VIOLET
        end

        it 'in Christmas time' do
          c = @t13.get(1, 5)
          expect(c.rank).to eq CR::Ranks::SUNDAY_UNPRIVILEGED
          expect(c.color).to eq CR::Colours::WHITE
        end

        it 'in Lent' do
          c = @t13.get(3, 23)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.color).to eq CR::Colours::VIOLET
        end

        it 'in Easter Time' do
          c = @t13.get(5, 11)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.color).to eq CR::Colours::WHITE
        end
      end

      describe 'solemnities and their cycles - ' do
        it 'end of Advent time' do
          c = @t13.get(12, 17)
          expect(c.rank).to eq CR::Ranks::FERIAL_PRIVILEGED
          expect(c.colour).to eq CR::Colours::VIOLET
        end

        it 'Nativity' do
          c = @t13.get(12, 25)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.title).to have_translation 'The Nativity of the Lord'
          expect(c.colour).to eq CR::Colours::WHITE
          expect(c.symbol).to eq :nativity
        end

        it 'day in the octave of Nativity' do
          c = @t13.get(12, 27)
          expect(c.rank).to eq CR::Ranks::FERIAL_PRIVILEGED
          expect(c.colour).to eq CR::Colours::WHITE
        end

        it 'Holy Family' do
          c = @t13.get(12, 29)
          expect(c.rank).to eq CR::Ranks::FEAST_LORD_GENERAL
          expect(c.title).to have_translation 'The Holy Family of Jesus, Mary and Joseph'
          expect(c.colour).to eq CR::Colours::WHITE
        end

        context 'when a Sunday does not occur between Dec 25 and Jan 1' do
          it 'is Holy Family on Friday Dec 30' do
            @t16 = described_class.new 2016
            c = @t16.get(12, 30)
            expect(c.title).to have_translation 'The Holy Family of Jesus, Mary and Joseph'
          end
        end

        it 'Epiphany' do
          c = @t13.get(1, 6)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.title).to have_translation 'The Epiphany of the Lord'
          expect(c.colour).to eq CR::Colours::WHITE
        end

        it 'Baptism of the Lord' do
          c = @t13.get(1, 12)
          expect(c.rank).to eq CR::Ranks::FEAST_LORD_GENERAL
          expect(c.title).to have_translation 'The Baptism of the Lord'
          expect(c.colour).to eq CR::Colours::WHITE
        end

        it 'Ash Wednesday' do
          c = @t13.get(3, 5)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.title).to have_translation 'Ash Wednesday'
          expect(c.colour).to eq CR::Colours::VIOLET
        end

        it 'Palm Sunday' do
          c = @t13.get(4, 13)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.title).to have_translation 'Palm Sunday of the Passion of the Lord'
          expect(c.colour).to eq CR::Colours::RED
        end

        it 'Good Friday' do
          c = @t13.get(4, 18)
          expect(c.rank).to eq CR::Ranks::TRIDUUM
          expect(c.title).to have_translation 'Friday of the Passion of the Lord'
          expect(c.colour).to eq CR::Colours::RED
        end

        it 'Holy Saturday' do
          c = @t13.get(4, 19)
          expect(c.rank).to eq CR::Ranks::TRIDUUM
          expect(c.title).to have_translation 'Holy Saturday'
          expect(c.colour).to eq CR::Colours::VIOLET
        end

        it 'Resurrection' do
          c = @t13.get(4, 20)
          expect(c.rank).to eq CR::Ranks::TRIDUUM
          expect(c.title).to have_translation 'Easter Sunday of the Resurrection of the Lord'
          expect(c.colour).to eq CR::Colours::WHITE
          expect(c.symbol).to eq :easter_sunday
        end

        it 'Ascension' do
          c = @t13.get(5, 29)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.title).to have_translation 'Ascension of the Lord'
          expect(c.colour).to eq CR::Colours::WHITE
        end

        it 'Pentecost' do
          c = @t13.get(6, 8)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.title).to have_translation 'Pentecost Sunday'
          expect(c.colour).to eq CR::Colours::RED
          expect(c.symbol).to eq :pentecost
        end

        it 'Trinity' do
          c = @t13.get(6, 15)
          expect(c.rank).to eq CR::Ranks::SOLEMNITY_GENERAL
          expect(c.title).to have_translation 'The Most Holy Trinity'
          expect(c.colour).to eq CR::Colours::WHITE
        end

        it 'Body of Christ' do
          c = @t13.get(6, 19)
          expect(c.rank).to eq CR::Ranks::SOLEMNITY_GENERAL
          expect(c.title).to have_translation 'The Most Holy Body and Blood of Christ'
          expect(c.colour).to eq CR::Colours::WHITE
        end

        it 'Sacred Heart' do
          c = @t13.get(6, 27)
          expect(c.rank).to eq CR::Ranks::SOLEMNITY_GENERAL
          expect(c.title).to have_translation 'The Most Sacred Heart of Jesus'
          expect(c.colour).to eq CR::Colours::WHITE
        end

        it 'Christ the King' do
          c = @t13.get(11, 23)
          expect(c.rank).to eq CR::Ranks::SOLEMNITY_GENERAL
          expect(c.title).to have_translation 'Our Lord Jesus Christ, King of the Universe'
          expect(c.colour).to eq CR::Colours::WHITE
        end

        describe 'other locales' do
          it 'Latin' do
            I18n.with_locale(:la) do
              c = @t13.get(11, 23)
              expect(c.title).to eq 'Domini nostri Iesu Christi universorum regis'
            end
          end

          it 'Czech' do
            I18n.with_locale(:cs) do
              c = @t13.get(11, 23)
              expect(c.title).to eq 'Ježíše Krista krále'
            end
          end

          it 'Italian' do
            I18n.with_locale(:it) do
              c = @t13.get(11, 23)
              expect(c.title).to eq "Nostro Signore Gesù Cristo Re dell'universo"
            end
          end
        end
      end

      # movable sanctorale feasts don't really belong in Temporale, but ...
      describe 'movable sanctorale feasts' do
        it 'Immaculate Heart' do
          c = @t13.get(6, 28)
          expect(c.title).to have_translation 'Immaculate Heart of Mary'
          expect(c.rank).to eq CR::Ranks::MEMORIAL_GENERAL
        end
      end
    end

    describe 'titles of Sundays and ferials' do
      def title_for(month, day)
        @t13.get(month, day).title
      end

      describe 'Ordinary time' do
        it 'Sunday' do
          expect(title_for(1, 19)).to have_translation '2nd Sunday in Ordinary Time'
        end

        it 'ferial' do
          expect(title_for(1, 13)).to have_translation 'Monday, 1st week in Ordinary Time'
        end
      end

      describe 'Advent' do
        it 'Sunday' do
          expect(title_for(12, 1)).to have_translation '1st Sunday of Advent'
        end

        it 'ferial' do
          expect(title_for(12, 2)).to have_translation 'Monday, 1st week of Advent'
        end

        it 'ferial before Christmas' do
          expect(title_for(12, 17)).to have_translation '17th December'
        end
      end

      describe 'Christmas time' do
        describe 'Octave of Christmas' do
          it 'ferial' do
            day = @t13.get(12, 30)
            expect(day.rank).to eq CR::Ranks::FERIAL_PRIVILEGED
            expect(day.title).to have_translation '6th day of Christmas Octave'
          end
        end

        describe 'after Octave of Christmas' do
          it 'ferial' do
            expect(title_for(1, 2)).to have_translation 'Thursday after Christmas Octave'
          end

          it 'Sunday' do
            expect(title_for(1, 5)).to have_translation '2nd Sunday after the Nativity of the Lord'
          end
        end

        describe 'after Epiphany' do
          it 'ferial' do
            expect(title_for(1, 7)).to have_translation 'Tuesday after Epiphany'
          end
        end
      end

      describe 'Lent' do
        describe 'before first Sunday' do
          it 'ferial' do
            expect(title_for(3, 6)).to have_translation 'Thursday after Ash Wednesday'
          end
        end

        it 'Sunday' do
          expect(title_for(3, 9)).to have_translation '1st Sunday of Lent'
        end

        it 'ferial' do
          expect(title_for(3, 10)).to have_translation 'Monday, 1st week of Lent'
        end

        describe 'Holy Week' do
          it 'ferial' do
            day = @t13.get(4, 14)
            expect(day.rank).to eq CR::Ranks::PRIMARY
            expect(day.title).to have_translation 'Monday of Holy Week'
          end
        end
      end

      describe 'Easter' do
        describe 'Easter Octave' do
          it 'ferial' do
            c = @t13.get(4, 22)
            expect(c.rank).to eq CR::Ranks::PRIMARY
            expect(c.title).to have_translation 'Easter Tuesday'
          end

          it 'Sunday (the octave day)' do
            c = @t13.get(4, 27)
            expect(c.rank).to eq CR::Ranks::PRIMARY
            expect(c.title).to have_translation '2nd Sunday of Easter'
          end
        end

        it 'Sunday' do
          expect(title_for(5, 4)).to have_translation '3rd Sunday of Easter'
        end

        it 'ferial' do
          expect(title_for(5, 5)).to have_translation 'Monday, 3rd week of Easter'
        end
      end

      describe 'other locales' do
        it 'Latin' do
          I18n.with_locale(:la) do
            expect(title_for(5, 5)).to eq 'Feria secunda, hebdomada III temporis paschalis'
          end
        end

        it 'Czech' do
          I18n.with_locale(:cs) do
            expect(title_for(5, 5)).to eq 'Pondělí po 3. neděli velikonoční'
          end
        end

        it 'French' do
          I18n.with_locale(:fr) do
            expect(title_for(5, 5)).to eq 'Lundi, 3ème semaine de Pâques'
          end
        end

        it 'Italian' do
          I18n.with_locale(:it) do
            expect(title_for(5, 5)).to eq 'Lunedì, III di Pasqua'
          end
        end
      end
    end
  end

  describe 'packaged extensions' do
    describe 'ChristEternalPriest' do
      let(:t) { described_class.new(2016, extensions: [CR::Temporale::Extensions::ChristEternalPriest]) }

      it 'adds the feast' do
        I18n.with_locale(:cs) do
          c = t.get(6, 8)
          expect(c.title).to eq 'Ježíše Krista, nejvyššího a věčného kněze'
          expect(c.rank).to eq CR::Ranks::FEAST_PROPER
          expect(c.colour).to eq CR::Colours::WHITE
        end
      end
    end
  end

  describe 'Solemnities transferred to a Sunday' do
    let(:year) { 2016 }
    let(:transferred) { [:epiphany, :ascension, :corpus_christi] }
    let(:t) { described_class.new(year, transfer_to_sunday: transferred) }
    let(:t_notransfer) { described_class.new(year) }

    it 'Epiphany' do
      date = Date.new(2017, 1, 8)
      expect(date).to be_sunday # make sure

      expect(t.epiphany).to eq date

      c = t.get(date)
      expect(c.rank).to eq CR::Ranks::PRIMARY
      expect(c.title).to have_translation 'The Epiphany of the Lord'
    end

    it 'Baptism of the Lord after transferred Epiphany' do
      date = Date.new(2017, 1, 9)
      expect(date).to be_monday # make sure

      expect(t.baptism_of_lord).to eq date

      c = t.get(date)
      expect(c.rank).to eq CR::Ranks::FEAST_LORD_GENERAL
      expect(c.title).to have_translation 'The Baptism of the Lord'
    end

    describe 'Ordinary Time numbering after transferred Epiphany' do
      it 'ferials correct' do
        first_ot_tuesday = Date.new(2017, 1, 10)
        expect(t.get(first_ot_tuesday)).to eq t_notransfer.get(first_ot_tuesday)
      end

      it 'Sundays correct' do
        second_ot_sunday = Date.new(2017, 1, 15)
        expect(t.get(second_ot_sunday)).to eq t_notransfer.get(second_ot_sunday)
      end
    end

    it 'Ascension' do
      date = Date.new(2017, 5, 28)
      expect(date).to be_sunday # make sure

      expect(t.ascension).to eq date

      c = t.get(date)
      expect(c.rank).to eq CR::Ranks::PRIMARY
      expect(c.title).to have_translation 'Ascension of the Lord'
    end

    it 'Corpus Christi' do
      date = Date.new(2017, 6, 18)
      expect(date).to be_sunday # make sure

      expect(t.corpus_christi).to eq date

      c = t.get(date)
      expect(c.rank).to eq CR::Ranks::SOLEMNITY_GENERAL
      expect(c.title).to have_translation 'The Most Holy Body and Blood of Christ'
    end

    it 'fails on an unsupported solemnity' do
      expect do
        described_class.new(2016, transfer_to_sunday: [:sacred_heart])
      end.to raise_exception(RuntimeError, /not supported/)
    end
  end
end

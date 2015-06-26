require 'spec_helper'

describe SanctoraleLoader do

  before :each do
    @s = Sanctorale.new
    @l = SanctoraleLoader.new
  end

  describe 'data sources' do
    describe '.load_from_string' do
      before :each do
        str = '1/3 : Ss.mi Nominis Iesu'
        @l.load_from_string @s, str
      end

      it 'loads one entry' do
        expect(@s.size).to eq 1
      end

      it 'loads date correctly' do
        expect(@s.get(1, 3).size).to eq 1
      end

      it 'loads title correctly' do
        expect(@s.get(1, 3)[0].title).to eq 'Ss.mi Nominis Iesu'
      end

      it 'sets default rank' do
        expect(@s.get(1, 3)[0].rank).to eq Ranks::MEMORIAL_OPTIONAL
      end

      it 'sets default colour - white' do
        expect(@s.get(1, 3)[0].colour).to eq Colours::WHITE
      end

      it 'loads explicit rank if given' do
        str = '1/25 f : In conversione S. Pauli, apostoli'
        @l.load_from_string @s, str
        expect(@s.get(1, 25)[0].rank).to eq Ranks::FEAST_GENERAL
      end
    end

    describe '.load_from_file' do
      it 'loads something from file' do
        @l.load_from_file(@s, File.join(%w{data universal-la.txt}))
        expect(@s.size).to be > 190
      end
    end
  end

  describe 'record/file format' do
    describe 'month as heading' do
      it 'drops item which does not contain a month' do
        str = '25 f : In conversione S. Pauli, apostoli'
        @l.load_from_string @s, str
        expect(@s).to be_empty
      end

      it 'loads a month heading and uses the month for subsequent records' do
        str = ['= 1', '25 f : In conversione S. Pauli, apostoli'].join "\n"
        @l.load_from_string @s, str
        expect(@s).not_to be_empty
        expect(@s.get(1, 25)).not_to be_empty
      end
    end

    describe 'colour' do
      it 'sets colour if specified' do
        str = '4/25 f R :  S. Marci, evangelistae'
        @l.load_from_string @s, str
        expect(@s.get(4, 25).first.colour).to eq Colours::RED
      end
    end

    describe 'rank' do
      it 'sets exact rank if specified' do
        # say we specify a proper calendar of a church dedicated to St. George
        str = '4/23 s1.4 R : S. Georgii, martyris'
        @l.load_from_string @s, str
        celeb = @s.get(4, 23).first
        expect(celeb.rank).to eq Ranks::SOLEMNITY_PROPER
      end
    end
  end

  describe 'logging' do
    it 'has a logger' do
      expect(CalendariumRomanum::SanctoraleLoader.logger).to be_a Log4r::Logger
    end

    it 'makes the logger accessible through Log4r\'s interface, too' do
      expect(Log4r::Logger['CalendariumRomanum::SanctoraleLoader']).to \
        be CalendariumRomanum::SanctoraleLoader.logger
    end

    describe 'events worth logging' do
      before :each do
        logger = CalendariumRomanum::SanctoraleLoader.logger
        logger.outputters.clear
        @buffer = ""
        logger.outputters << Log4r::IOOutputter.new('John', StringIO.new(@buffer))
      end

      it 'does not log valid entry' do
        str = '1/25 f : In conversione S. Pauli, apostoli'
        @l.load_from_string @s, str
        expect(@buffer).to be_empty
      end

      it 'logs line with invalid syntax' do
        str = 'line without standard beginning'
        @l.load_from_string @s, str
        expect(@buffer).to include 'Syntax error'
      end

      it 'logs entry with invalid month' do
        str = '100/25 f : In conversione S. Pauli, apostoli'
        @l.load_from_string @s, str
        expect(@buffer).to include 'Invalid date'
      end

      it 'logs entry with invalid day' do
        str = '1/250 f : In conversione S. Pauli, apostoli'
        @l.load_from_string @s, str
        expect(@buffer).to include 'Invalid date'
      end

      it 'logs invalid month heading' do
        str = '= 0'
        @l.load_from_string @s, str
        expect(@buffer).to include 'Invalid month'
      end

      it 'logs invalid rank' do
        str = '1/25 X : In conversione S. Pauli, apostoli'
        @l.load_from_string @s, str
        expect(@buffer).to include 'Syntax error'
      end

      it 'logs invalid numeric rank' do
        str = '4/23 s8.4 R : S. Georgii, martyris'
        @l.load_from_string @s, str
        expect(@s.get(4, 23).first.rank).to eq Ranks::SOLEMNITY_GENERAL
        expect(@buffer).to include 'rank'
      end
    end
  end
end

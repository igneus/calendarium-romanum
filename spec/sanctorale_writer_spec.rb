require 'spec_helper'

describe CR::SanctoraleWriter do
  let(:s) { CR::Sanctorale.new }
  let(:d) { CR::SanctoraleWriter.new }

  describe 'record/file format' do
    let(:celebration) do
      CR::Celebration.new(
        title: 'The Most Holy Name of Jesus',
        symbol: :name_jesus
      )  
    end
    let(:date) { CR::AbstractDate.new(1, 3) }
    let(:result) { d.send(:celebration_line, date, celebration) }

    describe 'day' do
      it 'prints the day' do
        expect(result[0]).to eq('3')
      end
    end

    describe 'title' do
      it 'prints the title' do
        expect(result).to include(': The Most Holy Name of Jesus')
      end
    end

    describe 'symbol' do
      it 'prints the symbol' do
        expect(result).to include(' name_jesus :')
      end
    end

    describe 'rank' do
      describe 'memorial' do
        let(:celebration) do
          CR::Celebration.new(
            rank: CR::Ranks::MEMORIAL_GENERAL
          )  
        end
        it 'includes m as rank' do
          expect(result).to include(' m ')
        end
      end
      describe 'feast' do
        let(:celebration) do
          CR::Celebration.new(
            rank: CR::Ranks::FEAST_GENERAL
          )  
        end
        it 'includes f as rank' do
          expect(result).to include(' f ')
        end
      end
      describe 'solemnity' do
        let(:celebration) do
          CR::Celebration.new(
            rank: CR::Ranks::SOLEMNITY_GENERAL
          )  
        end
        it 'includes s as rank' do
          expect(result).to include(' s ')
        end
      end

      describe 'feast of the lord' do
        let(:celebration) do
          CR::Celebration.new(
            rank: CR::Ranks::FEAST_LORD_GENERAL
          )  
        end
        it 'includes f2.5 as rank' do
          expect(result).to include(' f2.5 ')
        end
      end
    end
    
    describe 'colour' do
      describe 'red' do
        let(:celebration) do
          CR::Celebration.new(
            colour: CR::Colours::RED
          )  
        end
        it 'includes R as colour' do
          expect(result).to include(' R ')
        end
      end
    end
  end
  
  describe 'YAML front matter (YFM)' do
    it 'writes YFM if metadata is present' do
      s.metadata = { 'foo' => 'bar' }
      expect(d.write_to_string(s))
        .to eq("---\nfoo: bar\n---\n")
    end

    it 'does not write YFM if no metadata is present' do
      expect(d.write_to_string(s)).to eq('')
    end

    it 'does not write YFM if disabled by constructor option' do
      d = described_class.new front_matter: false

      s.metadata = {'foo' => 'bar'}
      expect(d.write_to_string(s)).to eq ''
    end
  end

  describe 'complete output' do
    let(:s) do
      s = CR::Sanctorale.new
      s.add(
        9,
        14,
        CR::Celebration.new(
          'Triumph of the Holy Cross',
          CR::Ranks::FEAST_LORD_GENERAL,
          CR::Colours::RED,
          :cross,
          CR::AbstractDate.new(9, 14)
        )
      )
      s.metadata = { 'metadata' => 'test' }

      s
    end

    it 'writes a simple but complete file correctly' do
      expected = <<EXPECTED
---
metadata: test
---

= 9
14 f2.5 R cross : Triumph of the Holy Cross
EXPECTED

      expect(d.write_to_string(s)).to eq(expected)
    end

    it 'can load the output with SanctoraleLoader' do
      serialized = d.write_to_string(s)
      loaded = CR::SanctoraleLoader.new.load_from_string(serialized)

      expect(loaded).to eq(s)
    end
  end
end

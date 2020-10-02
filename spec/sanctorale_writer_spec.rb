require 'spec_helper'

describe CR::SanctoraleWriter do
  let(:s) { CR::Sanctorale.new }
  let(:d) { CR::SanctoraleWriter.new }

  describe 'record/file format' do
    let(:celebration) do
      CR::Celebration.new(
        'The Most Holy Name of Jesus',
        CR::Ranks::MEMORIAL_OPTIONAL,
        CR::Colours::WHITE,
        :name_jesus,
        CR::AbstractDate.new(1, 3)
      )  
    end
    let(:result) { d.send(:celebration_line, celebration) }

    describe 'day' do
      it 'prints the day' do
        expect(result[0]).to eq('3')
      end
    end

    describe 'rank' do
      describe 'memorial' do
        let(:celebration) do
          CR::Celebration.new(
            'Saints Joachim and Anne',
            CR::Ranks::MEMORIAL_GENERAL,
            CR::Colours::WHITE,
            :joachim_anne,
            CR::AbstractDate.new(7, 26)
          )  
        end
        it 'includes m as rank' do
          expect(result).to include(' m ')
        end
      end
      describe 'feast' do
        let(:celebration) do
          CR::Celebration.new(
            'Saints Michael, Gabriel and Raphael, Archangels',
            CR::Ranks::FEAST_GENERAL,
            CR::Colours::WHITE,
            :archangels,
            CR::AbstractDate.new(9, 29)
          )  
        end
        it 'includes f as rank' do
          expect(result).to include(' f ')
        end
      end
      describe 'solemnity' do
        let(:celebration) do
          CR::Celebration.new(
            'Immaculate Conception of the Blessed Virgin Mary',
            CR::Ranks::SOLEMNITY_GENERAL,
            CR::Colours::WHITE,
            :bvm_immaculate,
            CR::AbstractDate.new(12, 8)
          )  
        end
        it 'includes s as rank' do
          expect(result).to include(' s ')
        end
      end

      describe 'feast of the lord' do
        let(:celebration) do
          CR::Celebration.new(
            'Transfiguration of the Lord',
            CR::Ranks::FEAST_LORD_GENERAL,
            CR::Colours::WHITE,
            :transfiguration,
            CR::AbstractDate.new(8, 6)
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
            'Saint Maximilian Mary Kolbe, priest and martyr',
            CR::Ranks::MEMORIAL_GENERAL,
            CR::Colours::RED,
            :kolbe,
            CR::AbstractDate.new(8, 14)
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
      s.metadata = {foo: 'bar'}
      expect(d.write_to_string(s))
        .to eq("---\nfoo: bar\n---\n")
    end

    it 'does not write YFM if no metadata is present' do
      expect(d.write_to_string(s)).to eq('')
    end
  end

  describe 'complete output' do
    it 'writes a simple but complete file correctly' do
      celebration =
        CR::Celebration.new(
          'Triumph of the Holy Cross',
          CR::Ranks::FEAST_LORD_GENERAL,
          CR::Colours::RED,
          :cross,
          CR::AbstractDate.new(9, 14)
        )
      s.add(9, 14, celebration)
      s.metadata = { metadata: 'test' }

      expected = <<~END
        ---
        metadata: test
        ---

        = 9
        14 f2.5 R cross : Triumph of the Holy Cross
      END

      expect(d.write_to_string(s)).to eq(expected)
    end
  end
end

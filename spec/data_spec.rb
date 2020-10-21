require_relative 'spec_helper'

describe CalendariumRomanum::Data do
  describe 'all available data files are included' do
    data_path = File.expand_path '../data', File.dirname(__FILE__)
    glob = File.join(data_path, '*.txt')

    Dir[glob].each do |file|
      next if File.basename(file) == 'easter_dates.txt'

      it "#{file} has it's Data entry" do
        expect(described_class.all)
          .to include(an_object_having_attributes(path: file))
      end
    end
  end

  describe 'all can be loaded' do
    described_class.each do |data|
      describe data.siglum do
        it 'can be loaded on it\'s own' do
          expect { data.load }.not_to raise_exception
        end

        it 'can be loaded with parents' do
          expect { data.load_with_parents }.not_to raise_exception
        end
      end
    end
  end

  describe '#load_with_parents' do
    let(:sanctorale) { CR::Data['czech-olomouc-cs'].load_with_parents }

    it 'loads the specified calendar' do
      expect(sanctorale.get(6, 30).first.title)
        .to eq 'Výročí posvěcení katedrály sv. Václava'
    end

    it 'loads the parent calendar' do
      c = sanctorale.get(5, 6).first

      expect(c.title).to eq 'Sv. Jana Sarkandra, kněze a mučedníka'
      expect(c.rank).to be CR::Ranks::MEMORIAL_PROPER
    end

    it 'loads the grand-parent calendar' do
      c = sanctorale.get(9, 28).first

      expect(c.title).to eq 'Sv. Václava, mučedníka, hlavního patrona českého národa'
      expect(c.rank).to eq CR::Ranks::SOLEMNITY_PROPER
    end
  end
end

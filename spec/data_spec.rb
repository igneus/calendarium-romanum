require_relative 'spec_helper'

describe CalendariumRomanum::Data do
  describe 'all available data files are included' do
    data_path = File.expand_path '../data', File.dirname(__FILE__)
    glob = File.join(data_path, '*.txt')

    Dir[glob].each do |file|
      it "#{file} has it's Data entry" do
        expect(described_class.all)
          .to include(an_object_having_attributes(path: file))
      end
    end
  end

  describe 'all can be loaded' do
    described_class.each do |data|
      it data.siglum do
        expect { data.load }.not_to raise_exception
      end
    end
  end
end

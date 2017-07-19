require_relative 'spec_helper'

describe CalendariumRomanum::Data do
  describe 'all available data files are included' do
    data_path = File.expand_path '../data', File.dirname(__FILE__)
    glob = File.join(data_path, '*.txt')

    Dir[glob].each do |file|
      it file do
        in_data = described_class.all.find {|f| f.path == file }
        expect(in_data).not_to be nil
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

require_relative 'spec_helper'

describe 'sanctorale data files' do
  let(:loader) { CR::SanctoraleLoader.new }

  data_path = File.expand_path '../data', File.dirname(__FILE__)
  glob = File.join(data_path, '*.txt')

  Dir[glob].each do |file|
    it "#{file} is loadable" do
      sanctorale = loader.load_from_file file
      expect(sanctorale).not_to be_empty
    end
  end
end

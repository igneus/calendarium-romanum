require_relative 'spec_helper'

require 'stringio'

describe 'results stay the same' do
  let(:sanctorale) { CR::Data::GENERAL_ROMAN.load }

  Dir[File.expand_path "../regression_dumps/*.txt", __FILE__]
    .collect {|f| [File.basename(f).to_i, f] }
    .sort_by {|year, path| year }
    .each do |year, path|
    it year do
      s = StringIO.new
      CR::CLI::Dumper.new(s).regression_tests_dump(year)

      expect(s.string).to eq File.read(path)
    end
  end
end

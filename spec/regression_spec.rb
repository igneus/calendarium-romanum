require_relative 'spec_helper'

require 'stringio'

describe 'Regressions', slow: true do
  all_dumps = Dir[File.expand_path "../regression_dumps/*.txt", __FILE__]
  transfers_dumps, year_dumps = all_dumps.partition do |path|
    File.basename(path).start_with? 'transfers_'
  end

  describe 'calendar contents' do
    year_dumps
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

  # solemnity transfers are checked for a greater range of years
  # than we check full calendar contents for
  describe 'solemnity transfers' do
    transfers_dumps.each do |path|
      years = File.basename(path).scan(/\d+/).collect(&:to_i)
      range = (years[0] .. years[1])

      it range do
        s = StringIO.new
        CR::CLI::Dumper.new(s).transfers_dump(range)

        expect(s.string).to eq File.read(path)
      end
    end
  end
end

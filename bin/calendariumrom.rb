#!/bin/env ruby

require 'thor'
require 'calendarium-romanum'
require 'log4r'

# load specified calendar files, print errors

module CalendariumRomanum
  class CLI < Thor

    desc 'errors FILE1, ...', 'finds errors in sanctorale data files'
    def errors(*files)
      logger = Log4r::Logger['CalendariumRomanum::SanctoraleLoader']
      logger.outputters << Log4r::StderrOutputter.new('stderr')

      files.each do |path|
        s = Sanctorale.new
        loader = SanctoraleLoader.new
        loader.load_from_file s, path
      end
    end
  end
end

if __FILE__ == $0
  CalendariumRomanum::CLI.start ARGV
end

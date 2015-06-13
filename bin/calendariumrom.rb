#!/bin/env ruby

require 'calendarium-romanum'
require 'log4r'

# load specified calendar files, print errors

include CalendariumRomanum

logger = Log4r::Logger['CalendariumRomanum::SanctoraleLoader']
logger.outputters << Log4r::StderrOutputter.new('stderr')

ARGV.each do |path|
  s = Sanctorale.new
  loader = SanctoraleLoader.new
  loader.load_from_file s, path
end
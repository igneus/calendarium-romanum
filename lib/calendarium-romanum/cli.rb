require 'thor'

# monkey patch preventing Thor from screwing formatting in our commands' long_desc
# credits: https://github.com/erikhuda/thor/issues/398#issuecomment-237400762
class Thor
  module Shell
    class Basic
      def print_wrapped(message, options = {})
         stdout.puts message
       end
    end
  end
end

module CalendariumRomanum

  # Implementation of the +calendariumrom+ executable.
  # _Not_ loaded by default when you +require+ the gem.
  #
  # @api private
  class CLI < Thor
    desc 'query [DATE]', 'show calendar information for a specified date/month/year'
    long_desc <<-EOS
show calendar information for a specified date/month/year

DATE formats:
not specified - today
2000-01-02    - single date
2000-01       - month
2000          - year
EOS
    option :calendar, default: 'universal-en', aliases: :c, desc: 'sanctorale data file to use'
    option :locale, default: 'en', aliases: :l, desc: 'locale to use for localized strings'
    def query(date_str = nil)
      I18n.locale = options[:locale]
      calendar = options[:calendar]
      if File.exist?(calendar)
        begin
          sanctorale = sanctorale_from_path(calendar)
        rescue CalendariumRomanum::InvalidDataError
          die! 'Invalid file format.'
        end
      else
        data_file = Data[calendar]

        if data_file.nil?
          die! "Invalid calendar. Either loading a calendar from filesystem did not succeed, \n or a preinstalled calendar was specified which doesn't exist. See subcommand `calendars` for valid options."
        end
        sanctorale = data_file.load
      end

      pcal = PerpetualCalendar.new sanctorale: sanctorale

      if date_str
        begin
          parsed_date = Util::DateParser.new(date_str)
          parsed_date.date_range.each do |day|
            print_single_date(pcal, day)
          end
        rescue ArgumentError
          die! 'Invalid date.'
        end
      else
        print_single_date(pcal, Date.today)
      end
    end

    desc 'calendars', 'list calendars available for querying'
    def calendars
      Data.each {|c| puts c.siglum }
    end

    desc 'errors FILE1, ...', 'find errors in sanctorale data files'
    def errors(*files)
      files.each do |path|
        begin
          sanctorale_from_path path
        rescue Errno::ENOENT, InvalidDataError => err
          die! err.message
        end
      end
    end

    desc 'cmp FILE1, FILE2', 'detect differences between two sanctorale data files'
    def cmp(a, b)
      Comparator.new.call(a, b)
    end

    desc 'dump YEAR', 'print calendar of the specified year for use in regression tests'
    def dump(year)
      Dumper.new.regression_tests_dump year.to_i
    end

    desc 'version', 'print version information'
    def version
      puts 'calendarium-romanum CLI'
      puts "calendarium-romanum: version #{CalendariumRomanum::VERSION}, released #{CalendariumRomanum::RELEASE_DATE}"
    end

    private

    def die!(message, code = 1)
      STDERR.puts message
      exit code
    end

    def print_single_date(calendar, date)
      day = calendar.day date

      puts date
      puts "season: #{day.season.name}"
      puts

      rank_length = day.celebrations.collect {|c| c.rank.short_desc.nil? ? 0 : c.rank.short_desc.size }.max
      day.celebrations.each do |c|
        if [Ranks::PRIMARY, Ranks::TRIDUUM].include? c.rank
          puts c.title
        elsif !c.rank.short_desc.nil?
          print c.rank.short_desc.rjust(rank_length)
          print ' : '
          puts c.title
        end
      end
    end
  end
end

# required files reopen the CLI class - require after the class'es main definition
# in order to prevent superclass mismatch errors
require_relative 'cli/helper'
require_relative 'cli/dumper'
require_relative 'cli/comparator'

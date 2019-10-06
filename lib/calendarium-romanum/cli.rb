require 'thor'

module CalendariumRomanum

  # Implementation of the +calendariumrom+ executable.
  # _Not_ loaded by default when you +require+ the gem.
  #
  # @api private
  class CLI < Thor
    include CalendariumRomanum::Util

    desc 'query 2007-06-05', 'show calendar information for a specified date'
    option :calendar, default: 'universal-en', aliases: :c
    option :locale, default: 'en', aliases: :l
    def query(date_str = nil)
      I18n.locale = options[:locale]
      calendar = options[:calendar]
      if File.exist?(calendar)
        begin
          sanctorale = SanctoraleLoader.new.load_from_file(calendar)
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
          parsed_date = DateParser.new(date_str)
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

    desc 'calendars', 'lists calendars available for querying'
    def calendars
      Data.each {|c| puts c.siglum }
    end

    desc 'errors FILE1, ...', 'finds errors in sanctorale data files'
    def errors(*files)
      loader = SanctoraleLoader.new
      files.each do |path|
        s = Sanctorale.new
        begin
          loader.load_from_file path, s
        rescue Errno::ENOENT, InvalidDataError => err
          die! err.message
        end
      end
    end

    desc 'cmp FILE1, FILE2', 'detect differences in rank and colour of corresponding celebrations'
    def cmp(a, b)
      loader = SanctoraleLoader.new
      paths = [a, b]
      sanctoralia = paths.collect {|source| loader.load_from_file source }
      names = paths.collect {|source| File.basename source }

      # a leap year must be chosen in order to iterate over
      # all possible days of a Sanctorale
      Year.new(1990).each_day do |d|
        a, b = sanctoralia.collect {|s| s.get(d) }

        0.upto([a.size, b.size].max - 1) do |i|
          ca = a[i]
          cb = b[i]
          compared = [ca, cb]

          if compared.index(&:nil?)
            notnili = compared.index {|c| !c.nil? }

            print date(d)
            puts " only in #{names[notnili]}:"
            puts celebration(compared[notnili])
            puts
            next
          end

          differences = %i(rank colour symbol).select do |property|
            ca.public_send(property) != cb.public_send(property)
          end

          next if differences.empty?
          print date(d)
          puts " differs in #{differences.join(', ')}"
          puts celebration(ca)
          puts celebration(cb)
          puts
        end
      end
    end

    desc 'version', 'print version information'
    def version
      puts 'calendarium-romanum CLI'
      puts "calendarium-romanum: version #{CalendariumRomanum::VERSION}, released #{CalendariumRomanum::RELEASE_DATE}"
    end

    private

    def date(d)
      "#{d.month}/#{d.day}"
    end

    def celebration(c)
      "#{c.rank.priority} #{c.colour.symbol} | #{c.title}"
    end

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

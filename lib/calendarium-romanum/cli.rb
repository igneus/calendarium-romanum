require 'thor'

module CalendariumRomanum

  class CLI < Thor
    include CalendariumRomanum::Util

    desc 'query 2007-06-05', 'show calendar information for a specified date'
    option :calendar, default: 'universal-en', aliases: :c
    option :locale, default: 'en', aliases: :l
    def query(date_str=nil)
      I18n.locale = options[:locale]

      data_file = Data[options[:calendar]]
      if data_file.nil?
        die! 'Invalid calendar. See subcommand `calendars` for valid options.'
      end
      sanctorale = data_file.load

      date =
        if date_str
          begin
            Date.parse(date_str)
          rescue ArgumentError
            die! 'Invalid date.'
          end
        else
          Date.today
        end
      calendar = Calendar.for_day(date, sanctorale)
      day = calendar.day date

      puts date
      puts "season: #{day.season.name}"
      puts

      rank_length = day.celebrations.collect {|c| c.rank.short_desc.size }.max
      day.celebrations.each do |c|
        print c.rank.short_desc.rjust(rank_length)
        print ' : '
        puts c.title
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
          ca, cb = a[i], b[i]
          compared = [ca, cb]
          differences = []

          if compared.index(&:nil?)
            notnili = compared.index {|c| !c.nil? }

            print date(d)
            puts " only in #{names[notnili]}:"
            puts celebration(compared[notnili])
            puts
            next
          end

          differences << 'rank' if ca.rank != cb.rank
          differences << 'colour' if ca.colour != cb.colour

          unless differences.empty?
            print date(d)
            puts " differs in #{differences.join(', ')}"
            puts celebration(ca)
            puts celebration(cb)
            puts
          end
        end
      end
    end

    private

    def date(d)
      "#{d.month}/#{d.day}"
    end

    def celebration(c)
      "#{c.rank.priority} #{c.colour.symbol} | #{c.title}"
    end

    def die!(message, code=1)
      STDERR.puts message
      exit code
    end
  end
end

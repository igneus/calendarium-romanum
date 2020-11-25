module CalendariumRomanum
  class CLI
    # "Queries" a Calendar.
    # Builds liturgical calendar according to the specified options and
    # prints calendar entries for the specified period.
    #
    # @api private
    class Querier
      include Helper

      def initialize(locale: :en, calendar: 'universal-en')
        @locale = locale
        @calendar = calendar
      end

      def call(date_str = nil)
        I18n.locale = @locale

        pcal = PerpetualCalendar.new sanctorale: sanctorale

        today = Date.today
        date_range = today..today

        if date_str
          begin
            date_range = DateParser.parse(date_str)
          rescue ArgumentError
            die! 'Invalid date.'
          end
        end

        date_range.each do |day|
          print_single_date(pcal, day)
        end
      end

      private

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

      def sanctorale
        if File.exist?(@calendar)
          begin
            sanctorale_from_path(@calendar)
          rescue CalendariumRomanum::InvalidDataError
            die! 'Invalid file format.'
          end
        elsif data_file = Data[@calendar]
          data_file.load
        else
          die! "Invalid calendar. Either loading a calendar from filesystem did not succeed, \n or a preinstalled calendar was specified which doesn't exist. See subcommand `calendars` for valid options."
        end
      end
    end
  end
end

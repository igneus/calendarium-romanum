require 'set'

module CalendariumRomanum

  # knows the fixed-date celebrations
  class Sanctorale

    def initialize
      @days = {}
      @solemnities = {}
      @symbols = Set.new
    end

    attr_reader :solemnities

    def add(month, day, celebration)
      date = AbstractDate.new(month, day)

      unless @days[date].nil? || @days[date].empty?
        present = @days[date][0]
        if present.rank != Ranks::MEMORIAL_OPTIONAL
          raise ArgumentError.new("On #{date} there is already a #{present.rank}. No more celebrations can be added.")
        elsif celebration.rank != Ranks::MEMORIAL_OPTIONAL
          raise ArgumentError.new("Celebration of rank #{celebration.rank} cannot be grouped, but there is already another celebration on #{date}")
        end
      end

      unless celebration.symbol.nil?
        if @symbols.include? celebration.symbol
          raise ArgumentError.new("Attempted to add Celebration with duplicate symbol #{celebration.symbol.inspect}")
        end

        @symbols << celebration.symbol
      end

      unless @days.has_key? date
        @days[date] = []
      end

      if celebration.solemnity?
        @solemnities[date] = celebration
      end

      @days[date] << celebration
    end

    # replaces content of the given day by given celebrations
    def replace(month, day, celebrations)
      date = AbstractDate.new(month, day)

      symbols_without_day = @symbols
      unless @days[date].nil?
        old_symbols = @days[date].collect(&:symbol).compact
        symbols_without_day = @symbols - old_symbols
      end

      new_symbols = celebrations.collect(&:symbol).compact
      duplicate = symbols_without_day.intersection new_symbols
      unless duplicate.empty?
        raise ArgumentError.new("Attempted to add Celebrations with duplicate symbols #{duplicate.to_a.inspect}")
      end

      @symbols = symbols_without_day
      @symbols.merge new_symbols

      if celebrations.first.solemnity?
        @solemnities[date] = celebrations.first
      elsif @solemnities.has_key? date
        @solemnities.delete date
      end

      @days[date] = celebrations.dup
    end

    # adds all Celebrations from another instance
    def update(sanctorale)
      sanctorale.each_day do |date, celebrations|
        replace date.month, date.day, celebrations
      end
    end

    def [](date)
      adate = date.is_a?(AbstractDate) ? date : AbstractDate.from_date(date)
      @days[adate] || []
    end

    # returns an Array with one or more Celebrations
    # scheduled for the given day
    #
    # expected arguments: Date or two Integers (month, day)
    def get(*args)
      if args.size == 1 && args[0].is_a?(Date)
        month = args[0].month
        day = args[0].day
      else
        month, day = args
      end

      date = AbstractDate.new(month, day)
      self[date]
    end

    # for each day for which an entry is available
    # yields an AbstractDate and an Array of Celebrations
    def each_day
      return to_enum(__method__) unless block_given?

      @days.each_pair do |date, celebrations|
        yield date, celebrations
      end
    end

    # returns count of the _days_ with celebrations filled
    def size
      @days.size
    end

    def empty?
      @days.empty?
    end

    def freeze
      @days.freeze
      @days.values.each(&:freeze)
      @solemnities.freeze
      super
    end

    def ==(b)
      self.class == b.class &&
        days == b.days
    end

    protected

    attr_reader :days
  end
end

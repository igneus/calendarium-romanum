require 'set'

module CalendariumRomanum

  # One of the two main {Calendar} components.
  # Contains celebrations with fixed date, mostly feasts of saints.
  #
  # Basically a mapping {AbstractDate} => Array<{Celebration}>
  # additionally enforcing some constraints:
  #
  # - for a given {AbstractDate} there may be multiple {Celebration}s,
  #   but only if all of them are in the rank of an optional
  #   memorial
  # - {Celebration#symbol} must be unique in the whole set of
  #   contained celebrations
  class Sanctorale

    def initialize
      @days = {}
      @solemnities = {}
      @symbols = Set.new
      @metadata = nil
    end

    # @!method dup
    #   Returns a copy of the receiver with properly copied internal
    #   data structures, i.e. a copy which can be safely modified without
    #   danger of unintentionally modifying the original instance.
    #   @return [Sanctorale]

    # @api private
    def initialize_dup(other)
      @days = other.days.dup
      @solemnities = other.solemnities.dup
      @symbols = other.symbols.dup
      @metadata = Marshal.load Marshal.dump other.metadata # deep copy
    end

    # Content subset - only {Celebration}s in the rank(s) of solemnity.
    #
    # @return [Hash<AbstractDate=>Celebration>]
    attr_reader :solemnities

    # Sanctorale metadata.
    #
    # Data files may contain YAML front matter.
    # If provided, it's loaded by {SanctoraleLoader} and
    # stored in this property.
    # All data files bundled in the gem (see {Data}) have YAML
    # front matter which is a Hash with a few standardized keys.
    # While YAML also supports top-level content of other types,
    # sanctorale data authors should stick to the convention
    # of using Hash as the top-level data structure of their
    # front matters.
    #
    # @return [Hash, nil]
    # @since 0.7.0
    attr_accessor :metadata

    # Adds a new {Celebration}
    #
    # @param month [Integer]
    # @param day [Integer]
    # @param celebration [Celebration]
    # @return [void]
    # @raise [ArgumentError]
    #   when performing the operation would break the object's invariant
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

    # Replaces content of the given day by given {Celebration}s
    #
    # @param month [Integer]
    # @param day [Integer]
    # @param celebrations [Array<Celebration>]
    # @param symbol_uniqueness [true|false]
    #   allows disabling symbol uniqueness check.
    #   Internal feature, not intended for use by client code.
    # @return [void]
    # @raise [ArgumentError]
    #   when performing the operation would break the object's invariant
    def replace(month, day, celebrations, symbol_uniqueness: true)
      date = AbstractDate.new(month, day)

      symbols_without_day = @symbols
      unless @days[date].nil?
        old_symbols = @days[date].collect(&:symbol).compact
        symbols_without_day = @symbols - old_symbols
      end

      new_symbols = celebrations.collect(&:symbol).compact
      duplicate = symbols_without_day.intersection new_symbols
      if symbol_uniqueness && !duplicate.empty?
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

    # Updates the receiver with {Celebration}s from another instance.
    #
    # For each date contained in +other+ the content of +self+
    # is _replaced_ by that of +other+.
    #
    # @param other [Sanctorale]
    # @return [void]
    # @raise (see #replace)
    def update(other)
      other.each_day do |date, celebrations|
        replace date.month, date.day, celebrations, symbol_uniqueness: false
      end
      rebuild_symbols
    end

    # Returns a new copy containing {Celebration}s from both self and +other+.
    #
    # @param other [Sanctorale]
    # @return [Sanctorale]
    # @since 0.9.0
    def merge(other)
      dup.tap {|dupped| dupped.update other }
    end

    # Returns a new instance containing {Celebration}s from +other+ which differ
    # from those in self.
    #
    # @param other [Sanctorale]
    # @return [Sanctorale]
    def difference(other)
      r = self.class.new
      other.each_day do |date, celebrations|
        r.replace(date.month, date.day, celebrations) if celebrations != self[date] && !celebrations.empty?
      end

      r
    end

    # Retrieves {Celebration}s for the given date
    #
    # @param date [AbstractDate, Date]
    # @return [Array<Celebration>] (may be empty)
    # @since 0.6.0
    def [](date)
      adate = date.is_a?(AbstractDate) ? date : AbstractDate.from_date(date)
      @days[adate] || []
    end

    # Retrieves {Celebration}s for the given date
    #
    # @overload get(date)
    #   @param date [AbstractDate, Date]
    # @overload get(month, day)
    #   @param month [Integer]
    #   @param day [Integer]
    # @return (see #[])
    def get(*args)
      date =
        if args.size == 1
          args[0]
        else
          AbstractDate.new(*args)
        end

      self[date]
    end

    # Enumerates dates for which any {Celebration}s are available
    #
    # @yield [AbstractDate, Array<Celebration>] the array is never empty
    # @return [void, Enumerator] if called without a block, returns +Enumerator+
    def each_day
      return to_enum(__method__) unless block_given?

      @days.each_pair do |date, celebrations|
        yield date, celebrations
      end
    end

    # Builds a new instance with the same dates as the receiver
    # and corresponding celebrations returned by the block.
    #
    # @yield [AbstractDate, Array<Celebration>] the array is never empty
    # @return [Sanctorale]
    def map_days
      r = self.class.new
      each_day do |date, celebrations|
        new_celebrations = yield(date, celebrations)
        next if new_celebrations.nil? || new_celebrations.empty?
        r.replace date.month, date.day, new_celebrations
      end

      r
    end

    # Builds a new instance with each celebration
    # replaced with result of yielding it to the block.
    #
    # @yield [Celebration]
    # @return [Sanctorale]
    def map_celebrations
      map_days do |date, celebrations|
        celebrations
          .collect {|c| yield c }
          .compact
      end
    end

    # Returns count of _days_ with {Celebration}s filled
    #
    # @return [Integer]
    def size
      @days.size
    end

    # It is empty if it doesn't contain any {Celebration}
    #
    # @return [Boolean]
    def empty?
      @days.empty?
    end

    # Freezes the instance
    def freeze
      @days.freeze
      @days.values.each(&:freeze)
      @solemnities.freeze
      super
    end

    # @return [Boolean]
    # @since 0.6.0
    def ==(b)
      self.class == b.class &&
        days == b.days
    end

    # Does this instance provide celebration identified by symbol +symbol+?
    #
    # @param symbol [Symbol]
    # @return [Boolean]
    # @since 0.9.0
    def provides_celebration?(symbol)
      @symbols.include? symbol
    end

    # If the instance contains a {Celebration} identified by the specified symbol,
    # returns it's date and the {Celebration} itself, nil otherwise.
    #
    # @param symbol [Symbol]
    # @return [Array<AbstractDate, Celebration>, nil]
    # @since 0.9.0
    def by_symbol(symbol)
      return nil unless provides_celebration? symbol

      @days.each_pair do |date, celebrations|
        found = celebrations.find {|c| c.symbol == symbol }
        return [date, found] if found
      end

      # reaching this point would mean that contents of @symbols and @days are not consistent
      raise 'this point should never be reached'
    end

    protected

    attr_reader :days, :symbols

    # Builds the registry of celebration symbols anew,
    # raises error if any duplicates are found.
    def rebuild_symbols
      @symbols = Set.new
      duplicates = []

      @days.each_pair do |date,celebrations|
        celebrations.each do |celebration|
          if @symbols.include?(celebration.symbol) &&
             !duplicates.include?(celebration.symbol) &&
             !celebration.symbol.nil?
            duplicates << celebration.symbol
          end

          @symbols << celebration.symbol
        end
      end

      unless duplicates.empty?
        raise ArgumentError.new("Duplicate celebration symbols: #{duplicates.inspect}")
      end
    end
  end
end

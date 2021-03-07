module CalendariumRomanum
  # Church authorities occasionally make ad hoc changes to the liturgical calendar
  # by moving a {Celebration} just for a given year to a more convenient date.
  # This class is responsible for storing and applying such changes.
  class DateOverrider
    # @param overrides [Hash<Date=>Symbol>]
    def initialize(overrides = {})
      @overrides = overrides
    end

    # Accepts {Temporale} and {Sanctorale}, returns them (if no changes apply)
    # or their copies with date changes applied.
    #
    # @param temporale [Temporale]
    # @param sanctorale [Sanctorale]
    # @return [Array<Temporale, Sanctorale>]
    def call(temporale, sanctorale)
      range = temporale.date_range

      for_year = @overrides.select {|date, _| range.include? date }

      return [temporale, sanctorale] if for_year.empty?

      for_temporale = {}
      for_sanctorale = {}
      for_year.each_pair do |date, symbol|
        to = temporale.provides_celebration?(symbol) ? for_temporale : for_sanctorale
        to[date] = symbol
      end

      new_sanctorale =
        for_sanctorale.empty? ?
          sanctorale :
          sanctorale.merge(sanctorale_layer(for_sanctorale, sanctorale))

      new_temporale =
        for_temporale.empty? ?
          temporale :
          temporale_class(for_temporale, temporale)
            .new(
              temporale.year,
              extensions: temporale.extensions,
              transfer_to_sunday: temporale.transfer_to_sunday
            )

      [new_temporale, new_sanctorale]
    end

    private

    # Returns a new {Sanctorale} applying +overrides+ to +sanctorale+.
    def sanctorale_layer(overrides, sanctorale)
      r = Sanctorale.new
      overrides.each do |date, symbol|
        orig_date, celebration = sanctorale.by_symbol(symbol)
        r.replace orig_date.month, orig_date.day, []
        r.add date.month, date.day, celebration
      end
      r
    end

    def temporale_class(overrides, temporale)
      Class.new(temporale.class) do
        overrides.each_pair do |date, symbol|
          define_method(symbol) { date }
        end
      end
    end
  end
end

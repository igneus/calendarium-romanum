module CalendariumRomanum
  # Provides {Calendar} event listeners implementing behaviour not fitting
  # in the standard calendar rules, but prescribed for given liturgical year
  # by the Holy See.
  class SpecialCasesHandler
    # Returns listeners relevant for the specified liturgical year.
    #
    # @return [Hash<Symbol=>#call>]
    def self.listeners(year)
      @listeners ||=
        begin
          {
            # see liturgical_law/2020_dubia_de_calendario_2022.md
            2021 => {
              # Birth of St. John Baptist celebrated one day earlier
              CR::Calendar::SanctoraleRetrievalEvent::EVENT_ID =>
              SanctoraleDateChangeListener.new(:baptist_birth, Date.new(2022, 6, 23)),
              # Sacred Heart receives first Vespers
              CR::Calendar::VespersResolutionEvent::EVENT_ID =>
              GrantFirstVespersListener.new(:sacred_heart)
            },
          }.freeze
        end

      @listeners[year] || {}
    end

    # Returns {EventDispatcher} pre-configured with listeners relevant for the
    # specified liturgical year.
    #
    # @return [EventDispatcher]
    def self.event_dispatcher(year)
      EventDispatcher.new.tap do |el|
        listeners(year).each_pair {|event, listener| el.add_listener event, listener }
      end
    end

    # For the given year changes any sanctorale celebration's date.
    class SanctoraleDateChangeListener
      def initialize(celebration_symbol, date)
        @symbol = celebration_symbol
        @date = date
      end

      # TODO: supply test coverage, quite probably it doesn't do everywhere exactly what it should
      def call(event, event_id)
        unless @celebration
          @orig_date, @celebration = event.calendar.sanctorale.by_symbol(@symbol)
        end

        return unless @celebration

        if event.date == @orig_date
          event.result = event.result.reject {|c| c.symbol == @symbol }
        end

        if event.date == @date
          event.result =
            if @celebration.rank == CR::Ranks::MEMORIAL_OPTIONAL &&
               (event.result.empty? || event.result[0].rank == CR::Ranks::MEMORIAL_OPTIONAL)
              event.result + [@celebration]
            else
              [@celebration]
            end
        end
      end
    end

    # For the given year changes any temporale celebration's date,
    # given that the celebration has it's own proper symbol.
    class TemporaleDateChangeListener
      def initialize(celebration_symbol, date)
        @symbol = celebration_symbol
        @date = date
      end

      def call(event, event_id)
        @orig_date ||= event.calendar.temporale.public_send @symbol
        return if @date == @orig_date

        if event.date == @orig_date
          # TODO must be handled!
        end

        if event.date == @date
          event.result = event.calendar.temporale[@orig_date]
        end
      end
    end

    # Grants first Vespers to a celebration even if it wouldn't get them
    # according to the standard logic of celebration precedence.
    class GrantFirstVespersListener
      def initialize(celebration_symbol)
        @symbol = celebration_symbol
      end

      def call(event, event_id)
        found = event.tomorrow.find {|c| c.symbol == @symbol }
        event.result = found if found
      end
    end
  end
end

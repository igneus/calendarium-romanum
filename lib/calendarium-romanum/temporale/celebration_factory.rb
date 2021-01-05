module CalendariumRomanum
  class Temporale
    # Provides factory methods building {Celebration}s
    # for temporale feasts
    class CelebrationFactory
      class << self
        # @yield [Symbol]
        # @return [void, Enumerator]
        def each
          return to_enum(__method__) unless block_given?

          celebrations.each do |symbol|
            yield public_send(symbol)
          end
        end

        # @return [Celebration]
        def first_advent_sunday
          Temporale.create_celebration(
            I18n.t('temporale.advent.sunday', week: Ordinalizer.ordinal(1)),
            Ranks::PRIMARY,
            Colours::VIOLET
          )
        end

        private

        def celebrations
          @celebrations ||= [:first_advent_sunday]
        end

        def celebration(symbol, rank, colour = Colours::WHITE, fixed_date: false, has_vigil: false, has_evening: false, move_if_sunday: false)
          define_singleton_method(symbol) do
            Temporale.create_celebration(
              proc { I18n.t("temporale.solemnity.#{symbol}") },
              rank,
              colour,
              symbol: symbol,
              date: fixed_date,
              has_vigil: has_vigil,
              has_evening: has_evening,
              move_if_sunday: move_if_sunday
            )
          end

          celebrations << symbol
        end
      end

      # @return [Celebration]
      # @!scope class
      celebration(:nativity, Ranks::PRIMARY, fixed_date: AbstractDate.new(12, 25), has_vigil: true)
      # @return [Celebration]
      # @!scope class
      celebration(:holy_family, Ranks::FEAST_LORD_GENERAL)
      # @return [Celebration]
      # @!scope class
      celebration(:mother_of_god, Ranks::SOLEMNITY_GENERAL, fixed_date: AbstractDate.new(1, 1))
      # @return [Celebration]
      # @!scope class
      celebration(:epiphany, Ranks::PRIMARY, has_vigil: true)
      # @return [Celebration]
      # @!scope class
      celebration(:baptism_of_lord, Ranks::FEAST_LORD_GENERAL)
      # @return [Celebration]
      # @!scope class
      celebration(:ash_wednesday, Ranks::PRIMARY, Colours::VIOLET)
      # @return [Celebration]
      # @!scope class
      celebration(:holy_thursday, Ranks::TRIDUUM, Colours::VIOLET, has_evening: true)
      # @return [Celebration]
      # @!scope class
      celebration(:good_friday, Ranks::TRIDUUM, Colours::RED)
      # @return [Celebration]
      # @!scope class
      celebration(:holy_saturday, Ranks::TRIDUUM, Colours::VIOLET)
      # @return [Celebration]
      # @!scope class
      celebration(:palm_sunday, Ranks::PRIMARY, Colours::RED)
      # @return [Celebration]
      # @!scope class
      celebration(:easter_sunday, Ranks::TRIDUUM, has_vigil: true)
      # @return [Celebration]
      # @!scope class
      celebration(:ascension, Ranks::PRIMARY, has_vigil: true)
      # @return [Celebration]
      # @!scope class
      celebration(:pentecost, Ranks::PRIMARY, Colours::RED, has_vigil: true)
      # @return [Celebration]
      # @!scope class
      celebration(:holy_trinity, Ranks::SOLEMNITY_GENERAL)
      # @return [Celebration]
      # @!scope class
      celebration(:corpus_christi, Ranks::SOLEMNITY_GENERAL)
      # @return [Celebration]
      # @!scope class
      celebration(:sacred_heart, Ranks::SOLEMNITY_GENERAL)
      # @return [Celebration]
      # @!scope class
      celebration(:christ_king, Ranks::SOLEMNITY_GENERAL)
      # @return [Celebration]
      # @!scope class
      celebration(:mother_of_church, Ranks::MEMORIAL_GENERAL)
      # @return [Celebration]
      # @!scope class
      celebration(:immaculate_heart, Ranks::MEMORIAL_GENERAL)
      # @return [Celebration]
      # @!scope class
      celebration(:saturday_memorial_bvm, Ranks::MEMORIAL_OPTIONAL)
    end
  end
end

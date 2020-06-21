module CalendariumRomanum
  # Utility loading {Sanctorale} from several sources
  # and building a single {Sanctorale} by layering them
  # over each other.
  class SanctoraleFactory
    class << self
      # Takes several {Sanctorale} instances, returns a new one,
      # resulting by merging them all together
      # (using {Sanctorale#update})
      #
      # @return [Sanctorale]
      #
      # @example
      #   include CalendariumRomanum
      #
      #   prague_sanctorale = SanctoraleFactory.create_layered(
      #     Data['czech-cs'].load, # Czech Republic
      #     Data['czech-cechy-cs'].load, # Province of Bohemia
      #     Data['czech-praha-cs'].load, # Archdiocese of Prague
      #   )
      def create_layered(*instances)
        r = Sanctorale.new
        instances.each {|i| r.update i }

        r.metadata = instances.last.metadata.dup
        r.metadata.delete 'extends'
        r.metadata['components'] = instances.collect(&:metadata)

        r
      end

      # Takes several filesystem paths, loads a {Sanctorale}
      # from each of them (using {SanctoraleLoader})
      # and then merges them (using {.create_layered})
      #
      # @return [Sanctorale]
      #
      # @example
      #   include CalendariumRomanum
      #
      #   my_sanctorale = SanctoraleFactory.load_layered_from_files(
      #     'my_data/general_calendar.txt',
      #     'my_data/particular_calendar.txt'
      #   )
      def load_layered_from_files(*paths)
        loader = SanctoraleLoader.new
        instances = paths.collect do |p|
          loader.load_from_file p
        end
        create_layered(*instances)
      end
    end
  end
end

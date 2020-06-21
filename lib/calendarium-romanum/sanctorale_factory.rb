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

        metadata = instances
                     .collect(&:metadata)
                     .select {|i| i.is_a? Hash }
        r.metadata = metadata.inject((metadata.first || {}).dup) {|merged,i| merged.update i }
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

      # Takes a single filesystem path. If the file's YAML front
      # matter references any parent data files using the
      # 'extends' key, it loads all the parents and assembles
      # the resulting {Sanctorale}.
      # If the data file doesn't reference any parents,
      # result is the same as {SanctoraleLoader#load_from_file}.
      #
      # @return [Sanctorale]
      # @since 0.7.0
      def load_with_parents(path)
        loader = SanctoraleLoader.new

        hierarchy = load_parent_hierarchy(path, loader)
        return hierarchy.first if hierarchy.size == 1

        create_layered *hierarchy
      end

      private

      def load_parent_hierarchy(path, loader)
        main = loader.load_from_file path
        return [main] unless main.metadata.has_key? 'extends'

        to_merge = [main]
        parents = main.metadata['extends']
        parents = [parents] unless parents.is_a? Array
        parents.reverse.each do |parent_path|
          expanded_path = File.expand_path parent_path, File.dirname(path)
          subtree = load_parent_hierarchy(expanded_path, loader)
          to_merge = subtree + to_merge
        end

        to_merge
      end
    end
  end
end

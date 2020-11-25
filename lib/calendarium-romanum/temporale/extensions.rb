module CalendariumRomanum
  class Temporale
    module Extensions
      # Returns all Temporale extensions defined by the gem.
      #
      # @return [Array<Module>]
      # @since 0.8.0
      def self.all
        constants
          .collect {|c| const_get(c) }
          .select {|c| c.is_a? Module }
      end
    end
  end
end

module CalendariumRomanum
  class Temporale
    module Extensions
      # Returns all Temporale extensions defined by the gem.
      #
      # @return [Array<Module>]
      def self.all
        constants
          .collect {|c| const_get(c) }
          .select {|c| c.is_a? Module }
      end
    end
  end
end

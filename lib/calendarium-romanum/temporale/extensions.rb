module CalendariumRomanum
  class Temporale
    module Extensions
      def self.all
        constants
          .collect {|c| const_get(c) }
          .select {|c| c.is_a? Module }
      end
    end
  end
end

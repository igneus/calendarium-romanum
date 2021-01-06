module CalendariumRomanum
  class Temporale
    # Provides utility methods for date arithmetics, available
    # both as mixin instance methods and module methods.
    module DateHelper
      extend self

      # @param weekday [Integer]
      # @param date [Date]
      # @return [Date]
      def weekday_before(weekday, date)
        if date.wday == weekday
          date - WEEK
        elsif weekday < date.wday
          date - (date.wday - weekday)
        else
          date - (date.wday + WEEK - weekday)
        end
      end

      # (see .weekday_before)
      def weekday_after(weekday, date)
        if date.wday == weekday
          date + WEEK
        elsif weekday > date.wday
          date + (weekday - date.wday)
        else
          date + (WEEK - date.wday + weekday)
        end
      end

      # @param date [Date]
      # @return [Date]
      def octave_of(date)
        date + WEEK
      end

      # @!method sunday_before(date)
      #   @param date [Date]
      #   @return [Date]
      # @!method monday_before(date)
      #   (see .sunday_before)
      # @!method tuesday_before(date)
      #   (see .sunday_before)
      # @!method wednesday_before(date)
      #   (see .sunday_before)
      # @!method thursday_before(date)
      #   (see .sunday_before)
      # @!method friday_before(date)
      #   (see .sunday_before)
      # @!method saturday_before(date)
      #   (see .sunday_before)

      # @!method sunday_after(date)
      #   @param date [Date]
      #   @return [Date]
      # @!method monday_after(date)
      #   (see .sunday_after)
      # @!method tuesday_after(date)
      #   (see .sunday_after)
      # @!method wednesday_after(date)
      #   (see .sunday_after)
      # @!method thursday_after(date)
      #   (see .sunday_after)
      # @!method friday_after(date)
      #   (see .sunday_after)
      # @!method saturday_after(date)
      #   (see .sunday_after)

      # @api private
      WEEKDAYS = %w(sunday monday tuesday wednesday thursday friday saturday).freeze
      WEEKDAYS.each_with_index do |weekday, weekday_i|
        define_method "#{weekday}_before" do |date|
          send('weekday_before', weekday_i, date)
        end

        define_method "#{weekday}_after" do |date|
          send('weekday_after', weekday_i, date)
        end
      end
    end
  end
end

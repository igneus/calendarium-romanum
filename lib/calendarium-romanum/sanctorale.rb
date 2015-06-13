module CalendariumRomanum

  # knows the fixed-date celebrations
  class Sanctorale

    def initialize
      @months = []
      13.times { @months << Hash.new } # 0 will be unused
    end

    def add(month, day, celebration)
      check_date! month, day

      unless @months[month].has_key? day
        @months[month][day] = []
      end

      @months[month][day] << celebration
    end

    # returns an Array with one or more Celebrations
    # scheduled for the given day
    #
    # expected arguments: Date or two Integers (month, day)
    def get(*args)
      if args.size == 1 && args[0].is_a?(Date)
        month = args[0].month
        day = args[0].day
      else
        month, day = args
      end

      check_date! month, day

      return @months[month][day] || []
    end

    # returns count of the _days_ with celebrations filled
    def size
      @months.inject(0) {|sum,n| sum + n.size }
    end

    def empty?
      size == 0
    end

    def validate_date(month, day=nil)
      month_valid = month >= 1 && month <= 12
      if day.nil? or not month_valid
        return month_valid
      end

      day_lte = case month
                when 2
                  28
                when 1, 3, 5, 7, 8, 10, 12
                  31
                else
                  30
                end
      day_valid = day > 0 && day <= day_lte

      return month_valid && day_valid
    end

    private

    def check_date!(month, day)
      unless validate_date month, day
        raise RangeError.new("Invalid month #{month}")
      end
    end
  end
end

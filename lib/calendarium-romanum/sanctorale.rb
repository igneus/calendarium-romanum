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

    # replaces content of the given day by given celebrations
    def replace(month, day, celebrations)
      check_date! month, day

      @months[month][day] = celebrations
    end

    # adds all Celebrations from another instance
    def update(sanctorale)
      sanctorale.each_day do |month, day, celebrations|
        replace month, day, celebrations
      end
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

    # for each day for which an entry is available
    # yields month, day (both Integers), Array of Celebrations
    def each_day
      @months.each_with_index do |month_content, month|
        month_content.keys.sort.each do |day|
          yield month, day, month_content[day]
        end
      end
    end

    # returns count of the _days_ with celebrations filled
    def size
      @months.inject(0) {|sum,n| sum + n.size }
    end

    def empty?
      size == 0
    end

    private

    def check_date!(month, day)
      unless month >= 1 && month <= 12
        raise RangeError.new("Invalid month #{month}.")
      end

      day_lte = case month
                when 2
                  28
                when 1, 3, 5, 7, 8, 10, 12
                  31
                else
                  30
                end

      unless day > 0 && day <= 31
        raise RangeError.new("Invalid day #{day}.")
      end
      unless day <= day_lte
        raise RangeError.new("Invalid day #{day} for month #{month}.")
      end
    end
  end
end

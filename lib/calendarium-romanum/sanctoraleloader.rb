module CalendariumRomanum

  # understands a plaintext calendar format
  # and knows how to transform it to Celebrations
  # and fill them in a Sanctorale
  #
  # Format of the file:
  # 1/31 m : S. Ioannis Bosco, presbyteri
  #
  # <month>/<day> <rank shortcut> : <title>
  # rank shortcut is optional, default value is optional memorial
  class SanctoraleLoader

    RANK_CODES = {
                  nil => Ranks::MEMORIAL_OPTIONAL,
                  'm' => Ranks::MEMORIAL_GENERAL,
                  'f' => Ranks::FEAST_GENERAL,
                  's' => Ranks::SOLEMNITY_GENERAL
                 }
    COLOUR_CODES = {
                    nil => Colours::WHITE,
                    'W' => Colours::WHITE,
                    'V' => Colours::VIOLET,
                    'G' => Colours::GREEN,
                    'R' => Colours::RED
                   }

    @@logger = Log4r::Logger.new(self.name)
    def self.logger
      @@logger
    end

    # dest should be a Sanctorale,
    # src anything with #each_line
    def load(dest, src)
      month_section = nil
      src.each_line do |l|
        # strip whitespace and comments
        l.sub!(/#.*/, '')
        l.strip!
        next if l.empty?

        # month section heading
        n = l.match /^=\s*(\d+)\s*$/
        unless n.nil?
          mi = n[1].to_i
          if dest.validate_date mi
            month_section = mi
          else
            @@logger.error "Invalid month #{mi}"
          end

          next
        end

        # celebration record
        m = l.match /^((\d+)\/)?(\d+)\s*([mfs])?\s*([WVRG])?\s*:(.*)$/
        if m.nil?
          @@logger.error "Syntax error, line skipped '#{l}'"
          next
        end

        month, day, rank, colour, title = m.values_at(2, 3, 4, 5, 6)
        month ||= month_section
        day = day.to_i
        month = month.to_i

        unless dest.validate_date month, day
          @@logger.error "Invalid date #{month}/#{day}"
          next
        end

        dest.add month, day, Celebration.new(
                                             title.strip,
                                             RANK_CODES[rank],
                                             COLOUR_CODES[colour]
                                            )
      end
    end

    alias_method :load_from_string, :load

    def load_from_file(dest, filename)
      self.load dest, File.open(filename)
    end
  end
end

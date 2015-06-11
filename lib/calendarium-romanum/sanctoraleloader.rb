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
          month_section = n[1].to_i
          next
        end

        # celebration record
        m = l.match /^((\d{1,2})\/)?(\d{1,2})\s*([mfs])?\s*:(.*)$/
        next if m.nil?

        month, day, rank, title = m.values_at 2, 3, 4, 5
        month ||= month_section
        month = month.to_i

        unless dest.validate_month month
          next
        end

        dest.add month, day.to_i, Celebration.new(title.strip, RANK_CODES[rank])
      end
    end

    alias_method :load_from_string, :load

    def load_from_file(dest, filename)
      self.load dest, File.open(filename)
    end
  end
end

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

    def load_from_string(dest, src)
      src.each_line do |l|
        l.strip!
        l.sub!(/#.*/, '')
        next if l.empty?

        m = l.match(/\A(\d{1,2})\/(\d{1,2})\s*([mfs])?\s*:(.*)\Z/)
        puts 'skip' if m.nil?
        next if m.nil?

        month, day, rank, title = m.values_at 1, 2, 3, 4
        dest.add month.to_i, day.to_i, Celebration.new(title.strip, RANK_CODES[rank])
      end
    end
  end
end

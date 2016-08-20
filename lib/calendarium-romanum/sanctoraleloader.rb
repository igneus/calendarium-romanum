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

    # dest should be a Sanctorale,
    # src anything with #each_line
    def load(dest, src)
      month_section = nil
      src.each_line.each_with_index do |l, li|
        line_num = li + 1

        # strip whitespace and comments
        l.sub!(/#.*/, '')
        l.strip!
        next if l.empty?

        # month section heading
        n = l.match /^=\s*(\d+)\s*$/
        unless n.nil?
          month_section = n[1].to_i
          unless month_section >= 1 && month_section <= 12
            raise error("Invalid month #{month_section}", line_num)
          end
          next
        end

        # celebration record
        m = l.match /^((\d+)\/)?(\d+)\s*(([mfs])(\d\.\d+)?)?\s*([WVRG])?\s*:(.*)$/
        if m.nil?
          raise error("Syntax error, line skipped '#{l}'", line_num)
          next
        end

        month, day, rank_char, rank_num, colour, title = m.values_at(2, 3, 5, 6, 7, 8)
        month ||= month_section
        day = day.to_i
        month = month.to_i

        rank = RANK_CODES[rank_char]
        if rank.nil?
          raise error("Invalid celebration rank code #{rank_char}", line_num)
        end

        if rank_num
          rank_num = rank_num.to_f
          rank_by_num = Ranks[rank_num]

          if rank_by_num.nil?
            raise error("Invalid celebration rank code #{rank_num}", line_num)
          elsif rank.priority.to_i != rank_by_num.priority.to_i
            raise error("Invalid combination of rank letter #{rank_char.inspect} and number #{rank_num}.", line_num)
          end

          rank = rank_by_num
        end

        dest.add month, day, Celebration.new(
                                             title.strip,
                                             rank,
                                             COLOUR_CODES[colour]
                                            )
      end
    end

    alias_method :load_from_string, :load

    def load_from_file(dest, filename, encoding='utf-8')
      self.load dest, File.open(filename, 'r', encoding: encoding)
    end

    private

    def error(message, line_number)
      RuntimeError.new("L#{line_number}: #{message}")
    end
  end
end

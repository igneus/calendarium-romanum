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
    }.freeze
    COLOUR_CODES = {
      nil => Colours::WHITE,
      'w' => Colours::WHITE,
      'v' => Colours::VIOLET,
      'g' => Colours::GREEN,
      'r' => Colours::RED
    }.freeze

    # dest should be a Sanctorale,
    # src anything with #each_line
    def load(src, dest = nil)
      dest ||= Sanctorale.new

      in_front_matter = false
      month_section = nil
      src.each_line.with_index(1) do |l, line_num|
        # skip YAML front matter
        if line_num == 1 && l.start_with?('---')
          in_front_matter = true
          next
        elsif in_front_matter
          if l.start_with?('---')
            in_front_matter = false
          end

          next
        end

        # strip whitespace and comments
        l.sub!(/#.*/, '')
        l.strip!
        next if l.empty?

        # month section heading
        n = l.match(/^=\s*(\d+)\s*$/)
        unless n.nil?
          month_section = n[1].to_i
          unless month_section >= 1 && month_section <= 12
            raise error("Invalid month #{month_section}", line_num)
          end
          next
        end

        begin
          celebration = load_line l, month_section
        rescue RangeError, RuntimeError => err
          raise error(err.message, line_num)
        end

        dest.add(
          celebration.date.month,
          celebration.date.day,
          celebration
        )
      end

      dest
    end

    alias load_from_string load

    def load_from_file(filename, dest = nil, encoding = 'utf-8')
      load File.open(filename, 'r', encoding: encoding), dest
    end

    private

    # parses a line containing celebration record,
    # returns a single Celebration
    def load_line(line, month_section = nil)
      # celebration record
      rank_letters = RANK_CODES.keys.compact.join('')
      m = line.match(/^((\d+)\/)?(\d+)\s*(([#{rank_letters}])?(\d\.\d{1,2})?)?\s*([WVRG])?\s*(:[\w\d_]+)?\s*:(.*)$/i)
      if m.nil?
        raise RuntimeError.new("Syntax error, line skipped '#{line}'")
      end

      month, day, rank_char, rank_num, colour, symbol_str, title = m.values_at(2, 3, 5, 6, 7, 8, 9)
      month ||= month_section
      day = day.to_i
      month = month.to_i

      rank = RANK_CODES[rank_char && rank_char.downcase]

      if rank_num
        rank_num = rank_num.to_f
        rank_by_num = Ranks[rank_num]

        if rank_by_num.nil?
          raise RuntimeError.new("Invalid celebration rank code #{rank_num}")
        elsif rank_char && (rank.priority.to_i != rank_by_num.priority.to_i)
          raise RuntimeError.new("Invalid combination of rank letter #{rank_char.inspect} and number #{rank_num}.")
        end

        rank = rank_by_num
      end

      symbol = nil
      if symbol_str
        symbol = symbol_str[1 .. -1].to_sym
      end

      Celebration.new(
        title.strip,
        rank,
        COLOUR_CODES[colour && colour.downcase],
        symbol,
        AbstractDate.new(month, day)
      )
    end

    def error(message, line_number)
      InvalidDataError.new("L#{line_number}: #{message}")
    end
  end
end

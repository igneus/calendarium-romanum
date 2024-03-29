require 'yaml'

module CalendariumRomanum

  # Understands a custom plaintext calendar format
  # and knows how to transform it to {Celebration}s
  # and fill them in a {Sanctorale}.
  #
  # For specification of the data format see {file:data/README.md}
  # of the data directory, For a complete example see e.g.
  # {file:universal-en.txt the file describing General Roman Calendar}.
  class SanctoraleLoader

    # @api private
    RANK_CODES = {
      nil => Ranks::MEMORIAL_OPTIONAL, # default
      'm' => Ranks::MEMORIAL_GENERAL,
      'mp' => Ranks::MEMORIAL_PROPER,
      'f' => Ranks::FEAST_GENERAL,
      'fl' => Ranks::FEAST_LORD_GENERAL,
      'fp' => Ranks::FEAST_PROPER,
      's' => Ranks::SOLEMNITY_GENERAL,
      'sp' => Ranks::SOLEMNITY_PROPER,
    }.freeze

    # @api private
    COLOUR_CODES = {
      nil => Colours::WHITE, # default
      'w' => Colours::WHITE,
      'v' => Colours::VIOLET,
      'g' => Colours::GREEN,
      'r' => Colours::RED
    }.freeze

    # @param error_handler [#call, nil]
    #   if provided, {SanctoraleLoader} on encountering errors
    #   in the data being loaded does not raise exception,
    #   but instead sends #call with the exception as argument
    def initialize(error_handler: nil)
      @error_handler = error_handler || method(:raise)
    end

    # Load from an object which understands +#each_line+
    #
    # @param src [String, File, #each_line]
    #   source of the loaded data
    # @param dest [Sanctorale, nil]
    #   objects to populate. If not provided, a new {Sanctorale}
    #   instance will be created
    # @return [Sanctorale]
    # @raise [InvalidDataError]
    def load(src, dest = nil)
      dest ||= Sanctorale.new

      in_front_matter = false
      front_matter = ''
      month_section = nil
      src.each_line.with_index(1) do |l, line_num|
        # skip YAML front matter
        if line_num == 1 && l.start_with?('---')
          in_front_matter = true
          front_matter += l
          next
        elsif in_front_matter
          if l.start_with?('---')
            in_front_matter = false
            dest.metadata = YAML.load(front_matter).freeze
          end

          front_matter += l

          next
        end

        # strip whitespace and comments
        l.sub!(/#.*/, '')
        l.strip!
        next if l.empty?

        # month section heading
        next if l.match(/^=\s*(\d+)\s*$/) do |n|
          month_section = n[1].to_i
          unless (1..12).include? month_section
            error!("Invalid month #{month_section}", line_num)
          end
          true
        end

        begin
          celebration = load_line l, month_section
        rescue RangeError, RuntimeError => err
          error!(err.message, line_num)
          next
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

    # Load from a filesystem path
    #
    # @param filename [String]
    # @param dest [Sanctorale, nil]
    # @param encoding [String]
    # @return (see #load)
    # @raise (see #load)
    def load_from_file(filename, dest = nil, encoding = 'utf-8')
      load File.open(filename, 'r', encoding: encoding), dest
    end

    private

    def line_regexp
      @line_regexp ||=
        begin
          rank_letters = RANK_CODES.keys.compact.join('|')
          colour_letters = COLOUR_CODES.keys.compact.join('')

          Regexp.new(
            '^((?<month>\d+)\/)?(?<day>\d+)' + # date
            '(\s+(?<rank_char>' + rank_letters + ')?(?<rank_num>\d\.\d{1,2})?)?' + # rank (optional)
            '(\s+(?<colour>[' + colour_letters + ']))?' + # colour (optional)
            '(\s+(?<symbol>[\w]{2,}))?' + # symbol (optional)
            '\s*:(?<title>.*)$', # title
            Regexp::IGNORECASE
          )
        end
    end

    # parses a line containing celebration record,
    # returns a single Celebration
    def load_line(line, month_section = nil)
      # celebration record
      m = line.match(line_regexp)
      if m.nil?
        raise RuntimeError.new("Syntax error, line skipped '#{line}'")
      end

      month = (m[:month] || month_section).to_i
      day = m[:day].to_i
      rank_char = m[:rank_char]
      rank_num = m[:rank_num]
      colour = m[:colour]
      symbol_str = m[:symbol]
      title = m[:title]

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
        symbol = symbol_str.to_sym
      end

      Celebration.new(
        title.strip,
        rank,
        COLOUR_CODES[colour && colour.downcase],
        symbol,
        AbstractDate.new(month, day)
      )
    end

    def error!(message, line_number)
      @error_handler.call InvalidDataError.new("L#{line_number}: #{message}")
    end
  end
end

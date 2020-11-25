require 'yaml'

module CalendariumRomanum

  # Understands a custom plaintext calendar format
  # and knows how to transform the {Celebration}s in a
  # {Sanctorale} to this format.
  #
  # For specification of the data format see {file:data/README.md}
  # of the data directory, For a complete example see e.g.
  # {file:universal-en.txt the file describing General Roman Calendar}.
  class SanctoraleWriter

    # @api private
    RANK_CODES = {
      Ranks::TRIDUUM => 's1.1',
      Ranks::PRIMARY => 's1.2',
      Ranks::SOLEMNITY_GENERAL => 's',
      Ranks::SOLEMNITY_PROPER => 's1.4',

      Ranks::FEAST_LORD_GENERAL => 'f2.5',
      Ranks::SUNDAY_UNPRIVILEGED => 'f2.6',
      Ranks::FEAST_GENERAL => 'f',
      Ranks::FEAST_PROPER => 'f2.8',
      Ranks::FERIAL_PRIVILEGED => 'f2.9',

      Ranks::MEMORIAL_GENERAL => 'm',
      Ranks::MEMORIAL_PROPER => 'm3.11',
      Ranks::MEMORIAL_OPTIONAL => 'm3.12',
      Ranks::FERIAL => 'm3.13',

      Ranks::COMMEMORATION => '4.0'
    }.freeze

    # @api private
    COLOUR_CODES = {
      Colours::WHITE => 'W',
      Colours::VIOLET => 'V',
      Colours::GREEN => 'G',
      Colours::RED => 'R'
    }.freeze

    # Write to an object which understands +#<<+
    #
    # @param src [Sanctorale]
    #   source of the loaded data
    # @param dest [String, File, #<<]
    #   object to populate. If not provided, a new {String}
    #   instance will be created and returned
    # @return [String]
    def write(src, dest = nil)
      dest ||= String.new

      # Write metadata to YAML if present
      unless src.metadata.nil? || src.metadata.empty?
        dest << src.metadata.to_yaml
        dest << "---\n"
      end

      # Write each celebration, grouped by month with headings
      current_month = 0
      src.each_day.sort_by{ |date, _| date }.each do |date, celebrations|
        if date.month > current_month
          current_month = date.month
          dest << "\n= #{current_month}\n"
        end

        celebrations.each do |c|
          dest << celebration_line(date, c)
          dest << "\n"
        end
      end

      dest
    end

    alias write_to_string write

    # Write to a filesystem path
    #
    # @param sanctorale [Sanctorale]
    # @param filename [String]
    # @param encoding [String]
    # @return [void]
    def write_to_file(sanctorale, filename, encoding = 'utf-8')
      File.open(filename, 'w', encoding: encoding) do |f|
        write(sanctorale, f)
      end
    end

    private

    # Convert a {Celebration} to a {String} for writing
    def celebration_line(date, celebration)
      line = "#{date.day} "

      unless celebration.rank == Ranks::MEMORIAL_OPTIONAL
        code = RANK_CODES[celebration.rank]
        line << "#{code} "
      end

      unless celebration.colour == Colours::WHITE
        code = COLOUR_CODES[celebration.colour]
        line << "#{code} "
      end

      unless celebration.symbol.nil?
        line << "#{celebration.symbol} "
      end

      line << ': '
      line << celebration.title

      line
    end
  end
end

module CalendariumRomanum
  class CLI
    # Mixin providing helper methods used by multiple CLI-related classes.
    #
    # @api private
    module Helper
      def sanctorale_from_path(path, error_handler: nil)
        loader = SanctoraleLoader.new error_handler: error_handler

        if path == '-'
          loader.load(STDIN)
        else
          loader.load_from_file(path)
        end
      end

      def die!(message, code = 1)
        STDERR.puts message
        exit code
      end
    end
  end
end

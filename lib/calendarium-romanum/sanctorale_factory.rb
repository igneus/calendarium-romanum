module CalendariumRomanum
  # conveniently creates sanctorale from several data files
  class SanctoraleFactory
    class << self
      # layers several sanctorale instances.
      def create_layered(*instances)
        r = Sanctorale.new
        instances.each {|i| r.update i }
        r
      end

      # loads and layers several sanctorale instances.
      def load_layered_from_files(*paths)
        loader = SanctoraleLoader.new
        instances = paths.collect do |p|
          loader.load_from_file p
        end
        create_layered(*instances)
      end
    end
  end
end

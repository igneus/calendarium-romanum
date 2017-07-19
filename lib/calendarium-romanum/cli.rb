require 'thor'

module CalendariumRomanum

  class CLI < Thor
    include CalendariumRomanum::Util

    desc 'errors FILE1, ...', 'finds errors in sanctorale data files'
    def errors(*files)
      loader = SanctoraleLoader.new
      files.each do |path|
        s = Sanctorale.new
        loader.load_from_file path, s
      end
    end

    desc 'cmp FILE1, FILE2', 'detect differences in rank and colour of corresponding celebrations'
    def rccompare(a, b)
      loader = SanctoraleLoader.new
      sanctorales = []

      [a, b].each do |source|
        s = Sanctorale.new
        loader.load_from_file s, source
        sanctorales << s
      end

      Year.new(1990).each_day do |d|
        celebs = sanctorales.collect {|s| s.get d.month, d.day }
        if celebs.find {|cc| cc.nil? }
          next
        end

        celebs[0].each_index do |i|
          if i >= celebs[1].size
            break
          end

          ca = celebs[0][i]
          cb = celebs[1][i]

          _print_cel = Proc.new {|c| puts "#{c.rank.priority} #{c.colour} | #{c.title}" }

          if ca.rank != cb.rank || ca.colour != cb.colour
            puts "#{d.month}/#{d.day}"
            _print_cel.call ca
            _print_cel.call cb
            puts
          end
        end
      end
    end
  end
end

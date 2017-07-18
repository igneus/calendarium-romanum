module CalendariumRomanum
  class Enum
    class << self
      def values(index_by: nil, &blk)
        defined?(@indexed) && raise(RuntimeError.new('initialized repeatedly'))

        @indexed = {}
        @all = yield.freeze

        @all.each_with_index do |val, i|
          val.freeze

          key = index_by ? val.public_send(index_by) : i
          @indexed[key] = val
        end

        @indexed.freeze
      end

      def all
        @all
      end

      def each
        @all.each {|i| yield i }
      end

      def [](key)
        @indexed[key]
      end
    end
  end
end

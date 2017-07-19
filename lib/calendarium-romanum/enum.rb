require 'forwardable'

module CalendariumRomanum
  # Utility class for definition of enumerated "types"
  class Enum
    class << self
      extend Forwardable

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

      def_delegators :@all, :each
      def_delegators :@indexed, :[]
    end
  end
end

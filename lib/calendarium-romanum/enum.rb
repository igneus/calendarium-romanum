require 'forwardable'

module CalendariumRomanum
  # Each subclass encapsulates a finite set of value objects.
  #
  # @abstract
  class Enum
    class << self
      extend Forwardable

      # @api private
      # @param index_by
      #   specifies which value objects' property contains
      #   unique internal identifier for use with {.[]}
      def values(index_by: nil)
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

      # Returns all contained value objects
      #
      # @return [Array]
      attr_reader :all

      # Enumerates contained value objects
      #
      # @!method each
      #   @yield value object
      #   @return [void]
      def_delegators :@all, :each

      # Allows accessing contained value objects by their
      # internal unique identifiers
      #
      # @!method [](identifier)
      #   @param identifier
      #   @return value object or nil
      def_delegators :@indexed, :[]
    end
  end
end

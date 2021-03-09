module CalendariumRomanum
  class EventDispatcher
    def initialize
      @listeners = {}
    end

    def add_listener(event_id, listener=nil, &blk)
      listener ||= blk
      unless listener
        raise ArgumentError.new('Either pass a callable as argument or provide a block')
      end

      @listeners[event_id] ||= []
      @listeners[event_id] << listener
    end

    def dispatch(event, event_id = nil)
      event_id ||= event.class::EVENT_ID

      listeners = @listeners[event_id]
      listeners.each {|l| l.call event, event_id } if listeners

      event
    end
  end
end

require_relative 'spec_helper'

describe CR::EventDispatcher do
  let(:subject) { described_class.new }

  let(:event) { Object.new }
  let(:event_id) { :some_id }

  describe '#dispatch' do
    it 'returns the event' do
      expect(subject.dispatch(event, 'anything')).to be event
    end

    describe 'an event listenned to' do
      it 'passes it to the listener' do
        listener = double(Proc)
        subject.add_listener event_id, listener

        expect(listener).to receive(:call).with(event, event_id)

        subject.dispatch event, event_id
      end
    end

    describe 'an event not listenned to' do
      it 'does not pass it to the listener' do
        listener = double(Proc)
        subject.add_listener event_id, listener

        expect(listener).not_to receive(:call)

        subject.dispatch event, :event_id_not_listenned_to
      end
    end

    describe 'order of listeners' do
      it 'is the order in which they were added' do
        order_tracker = []

        subject.add_listener(event_id) { order_tracker << 1 }
        subject.add_listener(event_id) { order_tracker << 2 }

        subject.dispatch event, event_id

        expect(order_tracker).to eq [1, 2]
      end
    end
  end
end

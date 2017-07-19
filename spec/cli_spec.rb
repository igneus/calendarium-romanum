require 'spec_helper'
require 'calendarium-romanum/cli'

describe CalendariumRomanum::CLI do
  let(:path_universal_la) { File.expand_path('../../data/universal-la.txt', __FILE__) }
  let(:path_universal_en) { File.expand_path('../../data/universal-en.txt', __FILE__) }
  describe 'subcommands' do
    describe 'errors' do
      it 'raises no exception' do
        described_class.start(['errors', path_universal_la])
      end

      it 'fails on a non-existent file' do
        expect do
          described_class.start(['errors', 'does-not-exist.txt'])
        end.to raise_exception Errno::ENOENT
      end
    end

    describe 'cmp' do
      it 'raises no exception' do
        described_class.start(['cmp', path_universal_la, path_universal_en])
      end
    end
  end
end

require 'spec_helper'
require 'calendarium-romanum/cli'

describe CalendariumRomanum::CLI, type: :aruba do
  let(:path_universal_la) { File.expand_path('../../data/universal-la.txt', __FILE__) }
  let(:path_universal_en) { File.expand_path('../../data/universal-en.txt', __FILE__) }

  before :each do
    prepend_environment_variable('RUBYLIB', File.expand_path('../../lib', __FILE__) + ':')
  end

  describe 'subcommands' do
    describe 'errors' do
      it 'raises no exception' do
        run_simple "calendariumrom errors #{path_universal_la}"
        assert_exit_status 0
      end

      it 'fails on a non-existent file' do
        expect do
          described_class.start(['errors', 'does-not-exist.txt'])
        end.to raise_exception Errno::ENOENT
      end
    end

    describe 'cmp' do
      it 'raises no exception' do
        run_simple "calendariumrom cmp #{path_universal_la} #{path_universal_en}"
        assert_exit_status 0
      end
    end
  end
end

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
      describe 'raises no exception' do
        before(:each) { run "calendariumrom errors #{path_universal_la}" }
        it { expect(last_command).to be_successfully_executed }
      end

      describe 'fails on a non-existent file' do
        before(:each) { run 'calendariumrom errors does-not-exist.txt' }
        it { expect(all_output).to include 'No such file or directory' }
        it { expect(last_command).to have_exit_status 1 }
      end
    end

    describe 'cmp' do
      describe 'raises no exception' do
        before(:each) { run "calendariumrom cmp #{path_universal_la} #{path_universal_en}" }
        it { expect(last_command).to be_successfully_executed }
      end
    end
  end
end

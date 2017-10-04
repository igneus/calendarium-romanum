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
      describe 'no errors detected' do
        before(:each) { run "calendariumrom errors #{path_universal_la}" }
        it { expect(last_command).to be_successfully_executed }
        it { expect(all_output).to be_empty }
      end

      describe 'non-existent file' do
        before(:each) { run 'calendariumrom errors does-not-exist.txt' }
        it { expect(all_output).to include 'No such file or directory' }
        it { expect(last_command).to have_exit_status 1 }
      end

      describe 'errors detected' do
        before(:each) do
          write_file 'data.txt', file_content
          run 'calendariumrom errors data.txt'
        end

        describe 'completely broken record' do
          let(:file_content) { 'invalid content' }

          it { expect(all_output).to eq "L1: Syntax error, line skipped 'invalid content'\n" }
          it { expect(last_command).to have_exit_status 1 }
        end

        describe 'wrong month title (month does not exist)' do
          let(:file_content) { "= 13\n" }

          it { expect(all_output).to start_with 'L1: Invalid month' }
          it { expect(last_command).to have_exit_status 1 }
        end
      end
    end

    describe 'cmp' do
      describe 'contents match' do
        before(:each) { run "calendariumrom cmp #{path_universal_la} #{path_universal_en}" }

        it { expect(all_output).to be_empty }
        it { expect(last_command).to be_successfully_executed }
      end
    end

    describe 'query' do
      describe 'correct season naming' do
        before(:each) { run "calendariumrom query 2017-10-03" }

        it { expect(all_output).to include "season: Ordinary Time" }
        it { expect(last_command).to be_successfully_executed }
      end
    end
  end
end

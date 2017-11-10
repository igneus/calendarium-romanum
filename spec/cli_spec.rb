require 'spec_helper'
require 'calendarium-romanum/cli'

describe CalendariumRomanum::CLI, type: :aruba do
  let(:path_universal_la) { CR::Data::GENERAL_ROMAN_LATIN.path }
  let(:path_universal_en) { CR::Data::GENERAL_ROMAN_ENGLISH.path }

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

      describe 'contents do not match' do
        before(:each) do
          write_file 'cal1.txt', content1
          write_file 'cal2.txt', content2
          run 'calendariumrom cmp cal1.txt cal2.txt'
        end

        describe 'in rank' do
          let(:content1) { '1/11 : St. None, abbot' }
          let(:content2) { '1/11 m : St. None, abbot' }

          it { expect(all_output).to include '1/11' }
          it { expect(all_output).to include 'St. None, abbot' }
          it { expect(all_output).to include 'differs in rank' }
          it { expect(last_command).to be_successfully_executed }
        end

        describe 'in colour' do
          let(:content1) { '1/11 : St. None, abbot' }
          let(:content2) { '1/11 R : St. None, abbot and martyr' }

          it { expect(all_output).to include '1/11' }
          it { expect(all_output).to include 'St. None, abbot' }
          it { expect(all_output).to include 'differs in colour' }
          it { expect(last_command).to be_successfully_executed }
        end

        describe 'in optional memorial count' do
          let(:content1) { '1/11 : St. None, abbot' }
          let(:content2) { "1/11 : St. None, abbot\n1/11 : St. Nulla, abbess" }

          it { expect(all_output).to include '1/11' }
          it { expect(all_output).to include 'St. Nulla, abbess' }
          it { expect(all_output).to include 'only in cal2.txt' }
          it { expect(last_command).to be_successfully_executed }
        end

        describe 'only in one source' do
          let(:content1) { '' }
          let(:content2) { '1/11 : St. None, abbot' }

          it { expect(all_output).to include '1/11' }
          it { expect(all_output).to include 'St. None, abbot' }
          it { expect(all_output).to include 'only in cal2.txt' }
          it { expect(last_command).to be_successfully_executed }
        end
      end
    end

    describe 'query' do
      describe 'invalid data file from file system' do
        before(:each) do
          write_file 'invalid.txt', 'Foo bar baz'
          run 'calendariumrom query --calendar invalid.txt 2017-10-03'
        end

        it { expect(all_output).to include 'Invalid file format.' }
        it { expect(last_command).to have_exit_status 1 }
      end

      describe 'correct data file from file system' do
        before(:each) { run "calendariumrom query --calendar #{path_universal_la} 2017-10-03" }

        it { expect(all_output).to include 'season: Ordinary Time' }
        it { expect(last_command).to be_successfully_executed }
      end

      describe 'correct season naming' do
        before(:each) { run 'calendariumrom query 2017-10-03' }

        it { expect(all_output).to include 'season: Ordinary Time' }
        it { expect(last_command).to be_successfully_executed }
      end

      describe 'correct month querying' do
        before(:each) { run 'calendariumrom query 2015-06' }

        it { expect(all_output).to include 'Saint Cyril of Alexandria' }
        it { expect(all_output).to include 'Saint Anthony of Padua, priest and doctor' }
        it { expect(last_command).to be_successfully_executed }
      end

      describe 'correct year querying' do
        before(:each) { run 'calendariumrom query 2013' }

        it { expect(all_output).to include 'Saint John the Apostle and evangelist' }
        it { expect(all_output).to include 'Saint Paul of the Cross, priest' }
        it { expect(last_command).to be_successfully_executed }
      end
    end

    describe 'calendars' do
      before(:each) { run 'calendariumrom calendars' }

      it { expect(all_output).to include 'universal-en' }
      it { expect(all_output).to include 'czech-praha-cs' }
      it { expect(last_command).to be_successfully_executed }
    end

    describe 'version' do
      before(:each) { run 'calendariumrom version' }

      it { expect(all_output).to include CR::VERSION }
      it { expect(all_output).to include CR::RELEASE_DATE.strftime('%Y-%m-%d') }
    end
  end
end

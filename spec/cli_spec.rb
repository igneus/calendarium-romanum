require 'spec_helper'

describe CalendariumRomanum::CLI, type: :aruba, slow: true do
  let(:path_universal_la) { CR::Data::GENERAL_ROMAN_LATIN.path }
  let(:path_universal_en) { CR::Data::GENERAL_ROMAN_ENGLISH.path }

  before :each do
    prepend_environment_variable('RUBYLIB', File.expand_path('../../lib', __FILE__) + ':')
  end

  describe 'subcommands' do
    describe 'errors' do
      describe 'no errors detected' do
        before(:each) { run "calendariumrom errors #{path_universal_la}" }
        it do
          expect(last_command).to be_successfully_executed
          expect(all_output).to be_empty
        end
      end

      describe 'non-existent file' do
        before(:each) { run 'calendariumrom errors does-not-exist.txt' }
        it do
          expect(all_output).to include 'No such file or directory'
          expect(last_command).to have_exit_status 1
        end
      end

      describe 'errors detected' do
        before(:each) do
          write_file 'data.txt', file_content
          run 'calendariumrom errors data.txt'
        end

        describe 'completely broken record' do
          let(:file_content) { 'invalid content' }

          it do
            expect(all_output).to eq "L1: Syntax error, line skipped 'invalid content'\n"
            expect(last_command).to have_exit_status 1
          end
        end

        describe 'wrong month title (month does not exist)' do
          let(:file_content) { "= 13\n" }

          it do
            expect(all_output).to start_with 'L1: Invalid month'
            expect(last_command).to have_exit_status 1
          end
        end
      end
    end

    describe 'cmp' do
      describe 'contents match' do
        before(:each) { run "calendariumrom cmp #{path_universal_la} #{path_universal_en}" }

        it do
          expect(all_output).to be_empty
          expect(last_command).to be_successfully_executed
        end
      end

      describe 'contents do not match' do
        before(:each) do
          write_file 'cal1.txt', content1
          write_file 'cal2.txt', content2
          run "calendariumrom cmp #{options} cal1.txt cal2.txt"
        end
        let(:options) { '' }

        describe 'in rank' do
          let(:content1) { '1/11 : St. None, abbot' }
          let(:content2) { '1/11 m : St. None, abbot' }

          it do
            expect(all_output).to include '1/11'
            expect(all_output).to include 'St. None, abbot'
            expect(all_output).to include 'differs in rank'
            expect(last_command).to have_exit_status 1
          end
        end

        describe 'in rank, but it is ignored' do
          let(:options) { '--no-rank' }
          let(:content1) { '1/11 : St. None, abbot' }
          let(:content2) { '1/11 m : St. None, abbot' }

          it do
            expect(all_output).not_to include 'differs in rank'
            expect(last_command).to be_successfully_executed
          end
        end

        describe 'in colour' do
          let(:content1) { '1/11 : St. None, abbot' }
          let(:content2) { '1/11 R : St. None, abbot and martyr' }

          it do
            expect(all_output).to include '1/11'
            expect(all_output).to include 'St. None, abbot'
            expect(all_output).to include 'differs in colour'
            expect(last_command).to have_exit_status 1
          end
        end

        describe 'in title, but it is ignored by default' do
          let(:content1) { '1/11 : St. None, abbot' }
          let(:content2) { '1/11 : St. None, monk' }

          it do
            expect(all_output).not_to include 'differs'
            expect(last_command).to be_successfully_executed
          end
        end

        describe 'in title, and comparing it is enabled' do
          let(:content1) { '1/11 : St. None, abbot' }
          let(:content2) { '1/11 : St. None, monk' }
          let(:options) { '--title' }

          it do
            expect(all_output).to include 'differs in title'
            expect(last_command).to have_exit_status 1
          end
        end

        describe 'in optional memorial count' do
          let(:content1) { '1/11 : St. None, abbot' }
          let(:content2) { "1/11 : St. None, abbot\n1/11 : St. Nulla, abbess" }

          it do
            expect(all_output).to include '1/11'
            expect(all_output).to include 'St. Nulla, abbess'
            expect(all_output).to include 'only in cal2.txt'
            expect(last_command).to have_exit_status 1
          end
        end

        describe 'only in one source' do
          let(:content1) { '' }
          let(:content2) { '1/11 : St. None, abbot' }

          it do
            expect(all_output).to include '1/11'
            expect(all_output).to include 'St. None, abbot'
            expect(all_output).to include 'only in cal2.txt'
            expect(last_command).to have_exit_status 1
          end
        end
      end
    end

    describe 'merge' do
      before(:each) do
        write_file 'cal1.txt', content1
        write_file 'cal2.txt', content2
        run 'calendariumrom merge cal1.txt cal2.txt'
      end

      describe 'merges the two calendars' do
        let(:content1) { "1/11 : St. None, abbot\n1/12 : St. Nulla, abbess" }
        let(:content2) { "1/12 : St. Some\n1/13 : St. Other" }

        it do
          expect(all_output).to end_with "= 1\n11 : St. None, abbot\n12 : St. Some\n13 : St. Other\n"
        end
      end
    end

    describe 'diff' do
      before(:each) do
        write_file 'cal1.txt', content1
        write_file 'cal2.txt', content2
        run 'calendariumrom diff cal1.txt cal2.txt'
      end

      describe 'prints how the latter file differs from the first one' do
        let(:content1) { "1/11 : St. None, abbot\n1/12 : St. Nulla, abbess" }
        let(:content2) { "1/11 : St. None, abbot\n1/12 : St. Some" }

        it do
          expect(all_output).to end_with "= 1\n12 : St. Some\n"
        end
      end
    end

    describe 'query' do
      describe 'invalid data file from file system' do
        before(:each) do
          write_file 'invalid.txt', 'Foo bar baz'
          run 'calendariumrom query --calendar invalid.txt 2017-10-03'
        end

        it do
          expect(all_output).to include 'Invalid file format.'
          expect(last_command).to have_exit_status 1
        end
      end

      describe 'correct data file from file system' do
        before(:each) { run "calendariumrom query --calendar #{path_universal_la} 2017-10-03" }

        it do
          expect(all_output).to include 'season: Ordinary Time'
          expect(last_command).to be_successfully_executed
        end
      end

      describe 'correct season naming' do
        before(:each) { run 'calendariumrom query 2017-10-03' }

        it do
          expect(all_output).to include 'season: Ordinary Time'
          expect(last_command).to be_successfully_executed
        end
      end

      describe 'correct month querying' do
        before(:each) { run 'calendariumrom query 2015-06' }

        it do
          expect(all_output).to include 'Saint Cyril of Alexandria'
          expect(all_output).to include 'Saint Anthony of Padua, priest and doctor'
          expect(last_command).to be_successfully_executed
        end
      end

      describe 'correct year querying' do
        before(:each) { run 'calendariumrom query 2013' }

        it do
          expect(all_output).to include 'Saint John the Apostle and evangelist'
          expect(all_output).to include 'Saint Paul of the Cross, priest'
          expect(last_command).to be_successfully_executed
        end
      end

      describe 'prints primary celebrations' do
        before(:each) { run 'calendariumrom query 2018-12-25' }

        it do
          expect(all_output).to include "2018-12-25\nseason: Christmas Season\n\nChristmas"
          expect(last_command).to be_successfully_executed
        end
      end
    end

    describe 'calendars' do
      before(:each) { run 'calendariumrom calendars' }

      it do
        expect(all_output).to include 'universal-en'
        expect(all_output).to include 'czech-praha-cs'
        expect(last_command).to be_successfully_executed
      end
    end

    describe 'id' do
      before(:each) { run "calendariumrom id #{path_universal_la}" }

      it { expect(all_output).to start_with "basil_gregory\n" }
    end

    describe 'version' do
      before(:each) { run 'calendariumrom version' }

      it do
        expect(all_output).to include CR::VERSION
        expect(all_output).to include CR::RELEASE_DATE.strftime('%Y-%m-%d')
      end
    end
  end
end

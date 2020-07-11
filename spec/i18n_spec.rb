# coding: utf-8
require_relative 'spec_helper'

describe 'internationalization' do
  before :all do
    I18n.backend.load_translations
  end

  let(:temporale) { CR::Temporale.new(2016) }
  let(:easter_celebration) { temporale.get Date.new(2017, 4, 16) }

  describe 'supported locales' do
    before :each do
      @last_locale = I18n.locale
      I18n.locale = locale
    end

    after :each do
      I18n.locale = @last_locale
    end

    describe 'English' do
      let(:locale) { 'en' }

      it 'translates Temporale feast names' do
        expect(easter_celebration.title).to eq 'Easter Sunday'
      end

      it 'translates rank names' do
        rank = CR::Ranks::SUNDAY_UNPRIVILEGED
        expect(rank.desc).to eq 'Unprivileged Sundays'
        expect(rank.short_desc).to eq 'Sunday'
      end

      it 'translates day weekday_names' do
        sunday = CR::Day.new(date: Date.new(2018, 5, 20))
        expect(sunday.weekday_name).to eq 'Sunday'
      end
    end

    describe 'Czech' do
      let(:locale) { 'cs' }

      it 'translates Temporale feast names' do
        expect(easter_celebration.title).to eq 'Zmrtvýchvstání Páně'
      end

      it 'translates rank names' do
        rank = CR::Ranks::SUNDAY_UNPRIVILEGED
        expect(rank.desc).to eq 'Neprivilegované neděle'
        expect(rank.short_desc).to eq 'neděle'
      end

      it 'translates day weekday_names' do
        sunday = CR::Day.new(date: Date.new(2018, 5, 20))
        expect(sunday.weekday_name).to eq 'Neděle'
      end
    end
  end

  describe 'unsupported locale' do
    # I will be most happy when this locale one day moves to the 'supported' branch!
    let(:locale) { 'de' }

    it 'attemt to switch to it fails by default' do
      # because in spec_helper.rb we set `I18n.enforce_available_locales = true`
      expect do
        I18n.locale = locale
      end.to raise_exception I18n::InvalidLocale
    end
  end
end

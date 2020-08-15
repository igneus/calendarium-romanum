require_relative 'spec_helper'

require 'stringio'

describe 'results stay the same' do
  let(:sanctorale) { CR::Data::GENERAL_ROMAN.load }

  years = 2020..2030
  years.each do |year|
    it year do
      c = CR::Calendar.new year, sanctorale, vespers: true

      s = StringIO.new
      I18n.with_locale(:la) do
        CR::Dumper.new(s).call(c)
      end

      path = File.expand_path "../regression_dumps/#{year}.txt", __FILE__
      expect(s.string).to eq File.read(path)
    end
  end
end

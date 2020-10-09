require_relative 'spec_helper'

require 'stringio'

describe 'results stay the same' do
  let(:sanctorale) { CR::Data::GENERAL_ROMAN_LATIN.load }

  Dir[File.expand_path "../regression_dumps/*.txt", __FILE__]
    .collect {|f| [File.basename(f).to_i, f] }
    .sort_by {|year, path| year }
    .each do |year, path|
    it year do
      c = CR::Calendar.new year, sanctorale, vespers: true

      s = StringIO.new
      I18n.with_locale(:la) do
        CR::Dumper.new(s).call(c)
      end

      expect(s.string).to eq File.read(path)
    end
  end
end

require 'spec_helper'

class LiturgicalLawExample
  # make RSpec expectations available for the code example
  extend RSpec::Matchers
  extend RSpec::Core::Pending

  class << self
    def year
      # random year, but stays the same for the whole example/code block
      @year ||= rand(1970 .. 3000)
    end

    def years(from: 1970, to: 2300)
      from.upto(to)
    end

    def years_with(from: 1970, to: 2300)
      from
        .upto(to)
        .select {|y| yield y }
        .tap {|result| raise 'no matching year found' if result.empty? }
    end
  end
end

Dir[File.expand_path('../../liturgical_law/*.md', __FILE__)].each do |path|
  describe path, slow: true do
    document = File.read path

    MarkdownDocument.new(document).each_ruby_example do |code, line, last_paragraph|
      context = last_paragraph[0..50].gsub(/\s+/, ' ')
      context = context[0..context.rindex(' ')]

      it context do
        cls = Class.new(LiturgicalLawExample)
        cls.class_eval(code, path, line)
      end
    end
  end
end

require 'spec_helper'
require 'markly'

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

    last_paragraph = ''
    header_level = 0
    Markly.parse(document).each do |node|
      case node.type
      when :header
        last_paragraph = node.to_plaintext
      when :paragraph
        last_paragraph = node.to_plaintext
      when :code_block
        next if node.fence_info != 'ruby'

        line = node.source_position[:start_line]

        context = last_paragraph[0..50].gsub(/\s+/, ' ')
        context = context[0..context.rindex(' ')]

        it context do
          cls = Class.new(LiturgicalLawExample)
          cls.class_eval(node.string_content, path, line)
        end
      end
    end
  end
end

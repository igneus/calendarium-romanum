require 'spec_helper'

Dir[File.expand_path('../../liturgical_law/*.md', __FILE__)].each do |path|
  describe path do
    document = File.read path
    doc = MarkdownDocument.new document

    doc.each_ruby_example do |code, line|
      describe "example L#{line}" do
        it 'executes without failure' do
          cls = Class.new do
            # make RSpec expectations available for the code example
            extend RSpec::Matchers

            class << self
              def year
                # random year, but stays the same for the whole example/code block
                @year ||= rand(1970 .. 3000)
              end

              def years_with(from: 1970, to: 2300)
                from
                  .upto(to)
                  .select {|y| yield y }
                  .tap {|result| raise 'no matching year found' if result.empty? }
              end
            end
          end

          cls.class_eval(code, path, line)
        end
      end
    end
  end
end

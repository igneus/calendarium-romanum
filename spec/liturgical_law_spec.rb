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
          end

          cls.class_eval(code, path, line)
        end
      end
    end
  end
end

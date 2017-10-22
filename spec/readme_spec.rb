require 'spec_helper'

class MarkdownDocument
  def initialize(str)
    @str = str
  end

  def each_ruby_example
    example = nil
    line = nil
    @str.each_line.with_index(1) do |l, i|
      if example.nil?
        if example_beginning?(l)
          example = ''
          line = i + 1
        end
      elsif example_end?(l)
        yield example, line
        example = nil
      else
        example += l
      end
    end
  end

  protected

  def example_beginning?(line)
    line =~ /^```ruby/
  end

  def example_end?(line)
    line =~ /```/
  end
end

%w(README.md data/README.md).each do |path|
  describe path do
    before :each do
      STDERR.stub(:puts)
    end

    readme_path = File.expand_path('../../' + path, __FILE__)
    readme = File.read readme_path
    doc = MarkdownDocument.new readme

    doc.each_ruby_example do |code, line|
      describe "example L#{line}" do
        it 'executes without failure' do
          cls = Class.new
          cls.class_eval(code, readme_path, line)
        end
      end
    end
  end
end

require_relative 'spec_helper'

class RubySourceWithYard
  def initialize(source)
    @source = source
  end

  def each_example
    example = nil
    line = nil
    @source.each_line.with_index(1) do |l, i|
      if example.nil?
        if example_beginning?(l)
          example = ''
          line = i
        end
      elsif example_end?(l)
        yield example, line
        example = nil
      else
        example += l.sub(/^\s*#/, '')
      end
    end

    yield example, line if example
  end

  def example_beginning?(l)
    /# @example/ =~ l
  end

  def example_end?(l)
    /#/ !~ l ||
      /# @/ =~ l
  end
end

describe 'code examples in YARD specs' do
  Dir[File.dirname(__FILE__) + '/../lib/**/*.rb'].each do |path|
    cleanpath = File.expand_path path
    describe cleanpath do
      doc = RubySourceWithYard.new File.read cleanpath

      doc.each_example do |code, line|
        describe "example L#{line}" do
          it 'executes without failure' do
            cls = Class.new { include CalendariumRomanum }
            cls.class_eval(code, cleanpath, line)
          end
        end
      end
    end
  end
end

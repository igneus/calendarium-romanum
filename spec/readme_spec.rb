require 'spec_helper'

%w(README.md data/README.md).each do |path|
  describe path do
    before :each do
      # README examples sometimes print, but we don't want them
      # to distort test output
      allow(STDERR).to receive :puts
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

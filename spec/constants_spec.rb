require_relative 'spec_helper'

describe CR::Constants do
  let(:test_module) { Module.new { include CR::Constants } }

  it 'provides colour constants' do
    expect(test_module::RED).to be CR::Colours::RED
  end

  it 'provides season constants' do
    expect(test_module::LENT).to be CR::Seasons::LENT
  end

  it 'provides rank constants' do
    expect(test_module::MEMORIAL_GENERAL).to be CR::Ranks::MEMORIAL_GENERAL
  end

  it 'does not provide data constants' do
    expect { test_module::GENERAL_ROMAN_ENGLISH }
      .to raise_exception NameError
  end
end

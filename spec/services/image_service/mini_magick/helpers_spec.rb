require 'spec_helper'

describe ImageService::MiniMagick::Helpers do
  include ImageService::MiniMagick::Helpers

  describe '#to_percent' do
    it 'converts to correct string' do
      expect(to_percent(1)).to eq('100.00%')
      expect(to_percent(0.25)).to eq('25.00%')
      expect(to_percent(0.123456)).to eq('12.35%')
    end
  end

  describe '#to_absolute_geometry' do
    it 'converts to correct string' do
      expect(to_absolute_geometry(640, 480)).to eq('640x480')
      expect(to_absolute_geometry(-640, -480)).to eq('640x480')
    end
  end

  describe '#to_position' do
    it 'converts to correct string' do
      expect(to_position(10, 20)).to eq('+10+20')
      expect(to_position(-10, 20)).to eq('-10+20')
      expect(to_position(10, -20)).to eq('+10-20')
      expect(to_position(-10, -20)).to eq('-10-20')
    end
  end
end

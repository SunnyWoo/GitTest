require 'spec_helper'

describe IllustratorService do
  subject(:service) { IllustratorService.new }

  after do
    service.reset_counter
  end

  describe '#current_count' do
    it 'returns 0 if counter file is not created' do
      service.reset_counter
      expect(service.current_count).to eq(0)
    end

    it 'returns the value of counter file if counter file is created' do
      service.reset_counter
      service.touch
      expect(service.current_count).to eq(1)
    end
  end
end

require 'spec_helper'

describe SfExpress::Scope do
  describe '#execute' do
    context '#success', :vcr do
      Given(:result) { SfExpress::Scope.new.execute }
      Then { result['Scope']['Service']['name'] == 'INSURE' }
      And { result['Scope']['Service']['value'] == '20000' }
    end
  end
end

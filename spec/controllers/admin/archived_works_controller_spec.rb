require 'rails_helper'

RSpec.describe Admin::ArchivedWorksController, :admin, type: :controller do
  describe '#recopy' do
    Given(:layer) { create :layer, material_name: 'layer: test recopy' }
    Given(:work) { layer.work }
    Given(:archived_layer) { create :archived_layer, material_name: 'archived_layer: test recopy' }
    Given(:archived_work) { archived_layer.work }
    Given { work.archives << archived_work }

    When { post :recopy_layers, id: archived_work.id }
    Then { archived_work.reload.layers.first != archived_layer }
    And { archived_work.reload.layers.first.material_name == 'layer: test recopy' }
  end
end

require 'spec_helper'

describe WorkTemplateMask do
  context '#initialize' do
    Given(:mask_json) do
      { material_name: 'material_name', scale_x: '1.1', scale_y: '1.2',
        position_x: '1.2', position_y: '1.4', orientation: '0.0' }
    end
    Given!(:work_template_mask) { WorkTemplateMask.new(mask_json) }

    Then { work_template_mask.material_name == mask_json[:material_name] }
    And { work_template_mask.scale_x == mask_json[:scale_x] }
    And { work_template_mask.scale_y == mask_json[:scale_y] }
    And { work_template_mask.position_x == mask_json[:position_x] }
    And { work_template_mask.position_y == mask_json[:position_y] }
    And { work_template_mask.orientation == mask_json[:orientation] }
  end
end

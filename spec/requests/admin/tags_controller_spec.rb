require 'spec_helper'

describe Admin::TagsController, type: :request do
  before(:each) do
    login_admin
  end

  describe '#update_tagging_position' do
    Given(:tag) { create :tag }
    Given(:standardized_work_1) { create :standardized_work }
    Given(:standardized_work_2) { create :standardized_work }
    Given do
      standardized_work_1.tag_ids = [tag.id]
      standardized_work_2.tag_ids = [tag.id]
      standardized_work_1.taggings.first.update_column(:position, 1)
      standardized_work_2.taggings.first.update_column(:position, 2)
    end
    When { put tagging_position_admin_tag_path(tag, tagging_id: standardized_work_2.taggings.first.id, position: 1) }
    Then { standardized_work_2.taggings.first.position == 1 }
    Then { standardized_work_1.taggings.first.position == 2 }
  end

  describe '#remove_tagging_positions' do
    Given(:tag) { create :tag }
    Given(:standardized_work) { create :standardized_work }
    Given do
      standardized_work.tag_ids = [tag.id]
      tag.taggings.first.update_column(:position, 1)
    end
    When { delete tagging_position_admin_tag_path(tag, tagging_id: tag.taggings.first.id) }
    Then { tag.taggings.first.position.blank? }
  end
end

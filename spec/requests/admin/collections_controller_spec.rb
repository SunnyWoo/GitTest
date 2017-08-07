require 'spec_helper'

describe Admin::CollectionsController, type: :request do
  before(:each) do
    login_admin
  end

  context '#add_tag' do
    Given(:collection) { create :collection }
    Given(:tag) { create :tag }
    When { post add_tag_admin_collection_path(collection, tag_ids: [tag.id]) }
    Then { collection.tag_ids.include?(tag.id) }
  end

  context '#remove_tag' do
    Given(:collection) { create :collection }
    Given(:tag_1) { create :tag }
    Given(:tag_2) { create :tag }
    Given do
      collection.tags << tag_1
      collection.tags << tag_2
    end
    When { delete remove_tag_admin_collection_path(collection, tag_id: tag_1.id) }
    Then { collection.tag_ids.include?(tag_1.id) == false }
    And { collection.tag_ids.include?(tag_2.id) }
  end

  context 'collection work position' do
    Given(:collection) { create :collection }
    Given(:tag) { create :tag }
    Given(:standardized_work) { create :standardized_work }

    context '#update_work_position' do
      Given do
        standardized_work.tag_ids = [tag.id]
        collection.tags << tag
        collection.collection_works.create(work: standardized_work, position: 3 )
      end
      When { put work_position_admin_collection_path(collection,
                                                     work_id: standardized_work.id,
                                                     work_type: 'StandardizedWork',
                                                     position: 1) }
      Then { collection.collection_works.first.position == 1 }
    end

    context '#remove_work_positions' do
      Given do
        standardized_work.tag_ids = [tag.id]
        collection.tags << tag
        collection.collection_works.create(work: standardized_work, position: 3 )
      end
      When { delete work_position_admin_collection_path(collection,
                                                        work_id: standardized_work.id,
                                                        work_type: 'StandardizedWork') }
      Then { collection.collection_works.first.blank? }
    end
  end
end

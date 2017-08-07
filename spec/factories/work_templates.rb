# == Schema Information
#
# Table name: work_templates
#
#  id               :integer          not null, primary key
#  model_id         :integer
#  background_image :string(255)
#  overlay_image    :string(255)
#  aasm_state       :string(255)
#  masks            :json
#  created_at       :datetime
#  updated_at       :datetime
#

include ActionDispatch::TestProcess
FactoryGirl.define do
  factory :work_template do
    product { build(:product_model) }
    background_image { fixture_file_upload('spec/photos/test.jpg', 'image/jpeg') }
    overlay_image { fixture_file_upload('spec/photos/test.jpg', 'image/jpeg') }

    trait :with_draft do
      aasm_state :draft
    end

    trait :with_published do
      aasm_state :published
    end

    trait :with_trashed do
      aasm_state :trashed
    end
  end
end

# == Schema Information
#
# Table name: mobile_uis
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  description :string(255)
#  template    :string(255)
#  image       :string(255)
#  priority    :integer          default(1)
#  start_at    :date
#  end_at      :date
#  is_enabled  :boolean          default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#  default     :boolean          default(FALSE)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mobile_ui do
    title '偉大的圖片'
    template 'shop'
    image { fixture_file_upload("spec/photos/prev_test.jpg", "image/jpeg") }
    start_at 1.day.ago
    end_at 1.month.from_now
  end
end

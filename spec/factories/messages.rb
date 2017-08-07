# == Schema Information
#
# Table name: messages
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  title      :string(255)
#  body       :text
#  mail_to    :string(255)
#  created_at :datetime
#  updated_at :datetime
#  order_no   :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    user nil
    title "MyString"
    body "MyText"
    mail_to "MyString"
  end
end

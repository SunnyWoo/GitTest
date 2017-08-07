# == Schema Information
#
# Table name: notifications
#
#  id                           :integer          not null, primary key
#  message                      :string(255)
#  message_id                   :string(255)
#  created_at                   :datetime
#  updated_at                   :datetime
#  filter                       :json
#  delivery_at                  :datetime
#  deep_link                    :string(255)
#  jid                          :string(255)
#  filter_count                 :integer
#  notification_trackings_count :integer          default(0)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification do
    message 'test message'
    message_id '24950eba-5f43-5399-84bb-438bdd624f2c'
  end
end

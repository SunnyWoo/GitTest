# == Schema Information
#
# Table name: notes
#
#  id            :integer          not null, primary key
#  message       :text
#  user_id       :integer
#  noteable_id   :integer
#  noteable_type :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  user_type     :string(255)
#

class Note < ActiveRecord::Base
  belongs_to :noteable, polymorphic: true, touch: true
  belongs_to :user, polymorphic: true

  default_scope { order(:created_at) }

  delegate :email, to: :user, prefix: true, allow_nil: true

  def user_name
    Monads::Optional.new(user_email).gsub(/@.+$/, '').value
  end
end

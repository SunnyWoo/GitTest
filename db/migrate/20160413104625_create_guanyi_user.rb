class CreateGuanyiUser < ActiveRecord::Migration
  def change
    user = User.new
    user.password = Devise.friendly_token[0, 10]
    user.email = 'guanyi@commandp.com'
    user.skip_confirmation!
    user.save!
  end
end

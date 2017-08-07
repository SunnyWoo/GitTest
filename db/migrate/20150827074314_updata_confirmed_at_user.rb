class UpdataConfirmedAtUser < ActiveRecord::Migration
  def change
    User.update_all(confirmed_at: Time.zone.now)
  end
end

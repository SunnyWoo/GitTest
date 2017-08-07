class CreateDeliverUser < ActiveRecord::Migration
  def change
    user = User.find_by(email: 'deliverorder@commandp.com')
    if user
      user.skip_confirmation!
      user.save
    else
      new_user = User.new(email: 'deliverorder@commandp.com',
                          name: 'commandp-deliverorder',
                          password: 'commandp',
                          password_confirmation: 'commandp')
      new_user.skip_confirmation!
      new_user.save
    end
  end
end

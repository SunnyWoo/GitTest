namespace :user do
  task avatar_recreate: :environment do
    User.find_each do |user|
      if user.avatar
        begin
          user.avatar.recreate_versions!
          user.save!
          puts "ok user id:#{user.id}"
        rescue Exception => e
          puts "error user id:#{user.id} , msg:#{e}"
        end
      end
    end
  end
end
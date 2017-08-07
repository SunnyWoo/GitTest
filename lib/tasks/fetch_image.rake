namespace :carrierwave do
  desc "Fetch image from facebook to all users"
  task fetch: :environment do
    User.all.each do |user|
      if user.omniauths.count != 0
        user.remote_avatar_url = "https://graph.facebook.com/#{user.facebook_uid}/picture"
        user.save!
      end
    end
  end
end

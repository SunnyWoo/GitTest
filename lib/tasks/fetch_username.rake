namespace :facebook do
  desc "Fetch username from facebook to all users"
  task fetch: :environment do
    User.all.each do |user|
      if user.omniauths.count != 0
        omniauth = user.omniauths.where(provider: 'facebook').first
        unless user.facebook.nil?
          puts user.id
          omniauth.username = user.facebook.get_object('me')['name']
          omniauth.save
        end
      end
    end
  end
end

(0..39).each do |count|
  user = User.new(email: Faker::Internet.email, password: 'commandpfakeruser', role: :designer)
  user.profile = { 'name' => Faker::Name.name }
  avatar_path = "vendor/JPG/#{(count + 1).to_s.rjust(4, '0')}.jpg"
  user.avatar = File.open(avatar_path)
  user.save!
end

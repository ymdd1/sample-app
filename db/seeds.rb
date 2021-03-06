User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             user_name: "ExampleUser",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

99.times do |n|
  name  = Faker::Okinawa::Name.last_name
  email = "example-#{n+1}@railstutorial.org"
  user_name = "Example#{n+1}"
  password = "password"
  User.create!(name:  name,
               email: email,
               user_name: user_name,
               password:              password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end

users = User.order(:created_at).take(6)
50.times do
  content = Faker::Okinawa::Address.park
  users.each { |user| user.microposts.create!(content: content) }
end

users = User.all
user  = users.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
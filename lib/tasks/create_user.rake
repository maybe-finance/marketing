namespace :user do
  # Usage: rake 'user:create[test,test]'
  desc "Create a new user"
  task :create, [ :username, :password ] => :environment do |_, args|
    username = args[:username]
    password = args[:password]

    password_digest = ActionController::HttpAuthentication::Digest.ha1(
      { username: username, realm: ENV["AUTH_SECRET"] },
      password
    )

    User.create(username: username, password_digest: password_digest)
    puts "User '#{username}' created successfully."
  end
end

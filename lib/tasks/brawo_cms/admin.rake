# frozen_string_literal: true

require "bcrypt"

namespace :brawo_cms do
  namespace :admin do
    desc "Create a verified admin account: rails brawo_cms:admin:create[email,password]"
    task :create, %i[email password] => :environment do |_task, args|
      email = args[:email].presence || ENV.fetch("EMAIL", nil)
      password = args[:password].presence || ENV.fetch("PASSWORD", nil)

      if email.blank? || password.blank?
        abort "Usage: rails brawo_cms:admin:create[email,password]"
      end

      if BrawoCms::Account.exists?(email: email)
        abort "Account already exists for #{email}"
      end

      account = BrawoCms::Account.create!(
        email: email,
        status: :verified,
        role: :super_admin,
        password_hash: BCrypt::Password.create(password)
      )

      puts "Created admin account #{account.email}. Complete TOTP setup on first sign in."
    end
  end
end

require "log"

require "../database"
require "./user"

module Bantumi::Auth::UserRepo
  # Saves User to database
  #
  # NOTE: User's id field is updated if user it was blank
  def self.save_user!(user : User) : User
    if user.id.nil?
      create_user!(user)
    else
      update_user(user)
    end
  end

  # Persists user in database
  def self.create_user!(user : User) : User
    Log.debug { "Creating user in database: #{user.username}" }
    Database.connection do |connection|
      connection.query(
        "INSERT INTO users (username, fullname, email, avatar, location) \
        VALUES (?, ?, ?, ?, ?) \
        RETURNING id",
        user.username,
        user.fullname,
        user.email,
        user.avatar,
        user.address
      ) do |results|
        results.each { user.id = results.read(Int32) }
      end
    end

    user
  end

  def self.update_user(_user : User) : User
    raise "Method not implemented"
  end
end

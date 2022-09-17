require "log"

require "../database"
require "./user"

module Bantumi::Auth::UserRepo
  extend self

  # Saves User to database
  #
  # NOTE: User's id field is updated if user it was blank
  def save_user(user : User) : User
    if user_exists?(user)
      update_user(user)
    else
      create_user(user)
    end
  end

  # Persists user in database
  def create_user(user : User) : User
    Log.debug { "Creating user in database: #{user.username}" }
    Database.connection do |connection|
      user_id = connection.scalar(
        "INSERT INTO users (username, fullname, email, avatar, address) \
        VALUES (?, ?, ?, ?, ?) \
        RETURNING id",
        user.username,
        user.fullname,
        user.email,
        user.avatar,
        user.address
      ).as(Int64)

      user.id = user_id
    end

    user
  end

  def find_user_by_id(user_id : Int64) : User?
    Log.debug { "Fetching user ##{user_id}"}
    Database.connection do |connection|
      results = connection.query_one?(
        "SELECT username, fullname, email, avatar, address
         FROM users
         WHERE id = ?
         LIMIT 1",
        user_id,
        &.read(String, String?, String?, String?, String?)
      )
      next nil unless results

      username, fullname, email, avatar, address = results

      User.new(
        id: user_id,
        username: username,
        fullname: fullname,
        email: email,
        avatar: avatar,
        address: address
      )
    end
  end

  def user_exists?(user : User) : Bool
    Log.debug { "Searching for user `#{user.username}`" }
    Database.connection do |connection|
      user_found = connection.query_one?(
        "SELECT 1 FROM users WHERE id = ? OR username = ?",
        user.id,
        user.username,
        &.read(Int32)
      )

      !user_found.nil?
    end
  end

  def update_user(user : User) : User
    Log.debug { "Updating user ##{user.id}" }
    Database.connection do |connection|
      if user.id
        connection.exec(
          "UPDATE users SET fullname = ?, email = ?, avatar = ?, address = ? WHERE id = ?",
          user.fullname,
          user.email,
          user.avatar,
          user.address,
          user.id
        )
      else
        user_id = connection.query_one?(
          "UPDATE users SET fullname = ?, email = ?, avatar = ?, address = ? WHERE username = ? RETURNING id ",
          user.fullname,
          user.email,
          user.avatar,
          user.address,
          user.username,
          &.read(Int64)
        )
        user.id = user_id
      end
    end

    user
  end
end

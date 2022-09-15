require "db"
require "sqlite3"

require "./config"

module Bantumi::Database
  def self.connection(&block)
    DB.open(Config::DATABASE_CONNECTION_STRING, &block)
  end
end

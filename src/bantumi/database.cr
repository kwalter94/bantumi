require "db"
require "sqlite3"

require "./config"

module Bantumi::Database
  extend self

  def connection(&block : DB::Database -> T) forall T
    DB.open(Config::DATABASE_CONNECTION_STRING, &block)
  end
end

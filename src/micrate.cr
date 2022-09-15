require "micrate"
require "sqlite3"

require "./bantumi/config"

module Bantumi
  Micrate::DB.connection_url = Config::DATABASE_CONNECTION_STRING
  Micrate::Cli.run
end

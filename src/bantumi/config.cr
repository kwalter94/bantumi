require "dotenv"
require "kemal"

module Bantumi::Config
  Dotenv.load

  OAUTH_PROVIDER = ENV.fetch("OAUTH_PROVIDER", "github")
  OAUTH_CLIENT_ID = ENV.fetch("OAUTH_CLIENT_ID")
  OAUTH_CLIENT_SECRET = ENV.fetch("OAUTH_CLIENT_SECRET")
  OAUTH_REDIRECT_URL = ENV.fetch(
    "OAUTH_REDIRECT_URL",
    "#{Kemal.config.scheme}://#{Kemal.config.host_binding}:#{Kemal.config.port}/auth/callback"
  )

  DATABASE_CONNECTION_STRING = "sqlite3:./db/data.db"
end

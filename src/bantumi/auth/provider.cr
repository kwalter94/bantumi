require "log"

require "multi_auth"

require "../config"
require "./user"
require "./user_repo"

module Bantumi::Auth::Provider
  MultiAuth.config(Config::OAUTH_PROVIDER, Config::OAUTH_CLIENT_ID, Config::OAUTH_CLIENT_SECRET)

  # Login user using code obtained through github's oauth2 service
  def self.login(code : String): User?
    Log.info { "Initiating login with #{Config::OAUTH_PROVIDER}" }
    github_user = multi_auth.user({"code" => code})

    if github_user.nickname.nil?
      Log.warn { "Got github user without a username!: #{github_user.raw_json}" }
      return nil
    end

    user = User.new(
      username: github_user.nickname || "Unknown",
      fullname: github_user.name,
      email: github_user.email,
      avatar: github_user.image,
      address: github_user.location
    )

    UserRepo.save_user!(user)
  rescue error : NilAssertionError
    # Instead of throwing a sensible error when the provided authentication
    # params fail, the underlying oauth2 library throws a NilAssertionError
    # because the authentication provider does not return any
    Log.error(exception: error) { "Failed to log in user" }
    nil
  end

  # URI for external oauth2 provider service to start authentication
  def self.authorize_uri
    multi_auth.authorize_uri
  end

  private def self.multi_auth
    @@multi_auth ||= MultiAuth.make(Config::OAUTH_PROVIDER, Config::OAUTH_REDIRECT_URL)
  end
end

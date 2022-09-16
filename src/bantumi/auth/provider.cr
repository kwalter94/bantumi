require "log"

require "jwt"
require "multi_auth"

require "../config"
require "./user"
require "./user_repo"

module Bantumi::Auth::Provider
  extend self

  struct AuthenticationToken
    property token : String
    property expires : Time
    property user : User

    def initialize(@token, @expires, @user); end
  end

  # URI for external oauth2 provider service to start authentication
  def authorize_uri : String
    multi_auth.authorize_uri
  end

  private alias GithubUser  = MultiAuth::User

  private MINUTE = 60 # Seconds
  private HOUR = 60 * MINUTE
  private ACCESS_TOKEN_VALIDITY = 5 * MINUTE
  private REFRESH_TOKEN_VALIDITY = 24 * HOUR

  MultiAuth.config(Config::OAUTH_PROVIDER, Config::OAUTH_CLIENT_ID, Config::OAUTH_CLIENT_SECRET)

  # URI for external oauth2 provider service to start authentication
  def authorize_uri : String
    multi_auth.authorize_uri
  end

  # Login user using code obtained through github's oauth2 service
  #
  # Returns a refresh token that can be used to generate API access tokens
  def login(code : String): AuthenticationToken?
    Log.info { "Initiating login with #{Config::OAUTH_PROVIDER}" }
    github_user = multi_auth.user({"code" => code})

    if github_user.nickname.nil?
      Log.warn { "Got a github user without a username!: #{github_user.raw_json}" }
      return nil
    end

    user = UserRepo.save_user(github_user_to_local_user(github_user))

    generate_token(user, REFRESH_TOKEN_VALIDITY)
  rescue error : NilAssertionError
    # Instead of throwing a sensible error when the provided authentication
    # params fail, the underlying oauth2 library throws a NilAssertionError
    # because the authentication provider has not returned any!!!
    Log.error(exception: error) { "Failed to log in user" }
    nil
  end

  # Generates a new access token using the provided refresh token
  def refresh_access_token(refresh_token : String) : AuthenticationToken?
    user = validate_token(refresh_token)
    return nil unless user

    generate_token(user, ACCESS_TOKEN_VALIDITY)
  end

  def validate_token(token : String) : User?
    payload, _headers = JWT.decode(token, Config::JWT_SECRET, JWT::Algorithm::HS256)

    user_id = payload["user_id"].as_i?
    return nil unless user_id

    UserRepo.find_user_by_id(user_id)
  rescue e: JWT::DecodeError
    Log.warn(exception: e) { "Failed to decode jwt" }
    nil
  end

  private def multi_auth : MultiAuth::Engine
    @@multi_auth ||= MultiAuth.make(Config::OAUTH_PROVIDER, Config::OAUTH_REDIRECT_URL)
  end

  private def github_user_to_local_user(github_user : GithubUser) : User
    User.new(
      username: github_user.nickname || "Unknown",
      fullname: github_user.name,
      email: github_user.email,
      avatar: github_user.image,
      address: github_user.location
    )
  end

  private def make_access_token(user : User) : String
    generate_token(user, ACCESS_TOKEN_VALIDITY)
  end

  private def generate_token(user : User, validity : Int64) : AuthenticationToken
    user.id.not_nil!

    expires = Time.utc.to_unix + validity
    jwt_payload = { "user_id" => user.id, "exp" => expires}
    token = JWT.encode(jwt_payload, Config::JWT_SECRET, JWT::Algorithm::HS256)

    AuthenticationToken.new(token: token, expires: Time.unix(expires), user: user)
  end
end

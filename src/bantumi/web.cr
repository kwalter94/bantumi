require "json"

require "kemal"

require "./auth/provider"
require "./web/helpers"

module Bantumi::Web
  include Helpers::Macros
  extend Helpers::Methods

  get "/auth/login" do |env|
    env.redirect(Auth::Provider.authorize_uri)
  end

  get "/auth/callback" do |env|
    refresh_token = Auth::Provider.login(code: env.params.query["code"])

    if refresh_token.nil?
      render_ecr!("login-error")
    else
      set_cookie(env, "refresh", refresh_token.token, path: "/auth/refresh-token",
                                                      http_only: true,
                                                      expires: refresh_token.expires)
      env.redirect("/index.html")
    end
  end

  get "/auth/refresh-token" do |env|
    refresh_token = get_cookie(env, "refresh")
    access_token = Auth::Provider.refresh_access_token(refresh_token) if refresh_token

    if access_token.nil?
      render_json(env, { "message" => "Expired or invalid refresh token" }, status_code: 401)
    else
      render_json(env, {
        "token" => access_token.token,
        "expires" => access_token.expires.to_unix,
        "user" => access_token.user.to_hash
      })
    end
  end

  def self.start
    Kemal.run
  end
end

require "json"

require "kemal"

require "./auth/provider"

module Bantumi::Web
  get "/" do
    "Hello, Kemal"
  end

  get "/auth/login" do |env|
    env.redirect(Auth::Provider.authorize_uri)
  end

  get "/auth/callback" do |env|
    env.response.headers["Content-type"] = "application/json"
    user = Auth::Provider.login(code: env.params.query["code"])

    user
      .try(&.to_hash)
      .try(&.to_json)
  end

  def self.start
    Kemal.run
  end
end

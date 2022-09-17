require "kemal"

require "../auth/provider"
require "../auth/user"

module Bantumi::Web::Middleware
  # Add accessor for authenticated user
  class HTTP::Server::Context
    property! current_user : Bantumi::Auth::User
  end

  # Middleware for JWT authentication on all /api endpoints
  class Auth < Kemal::Handler
    exclude ["/api/auth/refresh-token"]

    def call(env : HTTP::Server::Context)
      return call_next(env) if exclude_match?(env) || !api_path_match?(env)

      return auth_error(env, "No authentication token provided") unless env.request.headers["Authorization"]?

      token = env.request.headers["Authorization"].gsub(/^Bearer\s+/, "")
      user = Bantumi::Auth::Provider.validate_token(token)
      return auth_error(env, "Invalid or expired authentication token") unless user

      env.current_user = user
      call_next(env)
    end

    def api_path_match?(env : HTTP::Server::Context) : Bool
      match = env.request.path =~ %r{^/api/.*}

      !match.nil?
    end

    def auth_error(env, message)
      env.response.status_code = 401
      env.response.content_type = "application/json"
      env.response.print({ error: message }.to_json)
    end
  end
end

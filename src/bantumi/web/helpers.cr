require "kemal"

module Bantumi::Web::Helpers
  module Macros
    # Wrapper for kemal"s render macro
    macro render_ecr!(template_name)
      render "src/bantumi/web/views/" + {{template_name}} + ".ecr"
    end
  end

  module Methods
    def set_cookie(env, name : String, value : String, **options)
      cookie = HTTP::Cookie.new(**options, name: name, value: value)
      env.response.cookies << cookie
    end

    def get_cookie(env, name : String) : String?
      return nil unless env.request.cookies[name]?

      env.request.cookies[name].value
    end

    def render_json(env, json : Hash(String, Object), status_code : Int32 = 200) : String
      env.response.headers["Content-type"] = "Application/json"
      env.response.status_code = status_code

      json.to_json
    end
  end
end

require "log"

require "./bantumi/web"

# TODO: Write documentation for `Bantumi`
module Bantumi
  VERSION = "0.1.0"

  Log.info { "Starting application..." }
  Bantumi::Web.start
end

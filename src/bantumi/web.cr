require "kemal"

module Bantumi::Web
  get "/" do
    "Hello, Kemal"
  end

  def self.start
    Kemal.run
  end
end

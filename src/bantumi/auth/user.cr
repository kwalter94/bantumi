module Bantumi::Auth
  struct User
    def initialize(@username, @fullname, @email, @avatar, @address, @id = nil); end

    property id : Int64?
    property username : String
    property fullname : String?
    property email : String?
    property avatar : String?
    property address : String?

    def to_hash
      {
        id: id,
        username: username,
        fullname: fullname,
        email: email,
        avatar: avatar,
        address: address
      }
    end
  end
end

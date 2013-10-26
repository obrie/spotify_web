## Generated from core.proto for 
require "beefcake"

module SpotifyWeb
  module Schema

    class Toplist
      include Beefcake::Message
    end

    class DecorationData
      include Beefcake::Message
    end

    class Toplist
      repeated :items, :string, 1
    end


    class DecorationData
      optional :username, :string, 1
      optional :full_name, :string, 2
      optional :image_url, :string, 3
      optional :large_image_url, :string, 5
      optional :first_name, :string, 6
      optional :last_name, :string, 7
      optional :facebook_uid, :string, 8
    end

  end
end

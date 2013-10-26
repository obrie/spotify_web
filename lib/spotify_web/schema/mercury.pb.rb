## Generated from mercury.proto for spotify.mercury.proto
require "beefcake"

module SpotifyWeb
  module Schema
    module Mercury

      class UserField
        include Beefcake::Message
      end

      class MercuryMultiGetRequest
        include Beefcake::Message
      end

      class MercuryMultiGetReply
        include Beefcake::Message
      end

      class MercuryRequest
        include Beefcake::Message
      end

      class MercuryReply
        include Beefcake::Message

        module CachePolicy
          CACHE_NO = 1
          CACHE_PRIVATE = 2
          CACHE_PUBLIC = 3
        end
      end

      class MercuryMultiGetRequest
        repeated :request, MercuryRequest, 1
      end


      class MercuryMultiGetReply
        repeated :reply, MercuryReply, 1
      end


      class MercuryRequest
        optional :uri, :string, 1
        optional :content_type, :string, 2
        optional :method, :bytes, 3
        optional :status_code, :sint32, 4
        optional :source, :string, 5
        repeated :user_fields, UserField, 6
      end


      class MercuryReply
        optional :status_code, :sint32, 1
        optional :status_message, :string, 2
        optional :cache_policy, MercuryReply::CachePolicy, 3
        optional :ttl, :sint32, 4
        optional :etag, :bytes, 5
        optional :content_type, :string, 6
        optional :body, :bytes, 7
      end

    end
  end
end

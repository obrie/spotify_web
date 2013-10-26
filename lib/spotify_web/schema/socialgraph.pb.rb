## Generated from socialgraph.proto for spotify.socialgraph.proto
require "beefcake"

module SpotifyWeb
  module Schema
    module Socialgraph

      class CountReply
        include Beefcake::Message
      end

      class UserListRequest
        include Beefcake::Message
      end

      class UserListReply
        include Beefcake::Message
      end

      class User
        include Beefcake::Message
      end

      class ArtistListReply
        include Beefcake::Message
      end

      class Artist
        include Beefcake::Message
      end

      class StringListRequest
        include Beefcake::Message
      end

      class StringListReply
        include Beefcake::Message
      end

      class TopPlaylistsRequest
        include Beefcake::Message
      end

      class TopPlaylistsReply
        include Beefcake::Message
      end

      class CountReply
        repeated :counts, :int32, 1
      end


      class UserListRequest
        optional :last_result, :string, 1
        optional :count, :int32, 2
        optional :include_length, :bool, 3
      end


      class UserListReply
        repeated :users, User, 1
        optional :length, :int32, 2
      end


      class User
        optional :username, :string, 1
        optional :subscriber_count, :int32, 2
        optional :subscription_count, :int32, 3
      end


      class ArtistListReply
        repeated :artists, Artist, 1
      end


      class Artist
        optional :artistid, :string, 1
        optional :subscriber_count, :int32, 2
      end


      class StringListRequest
        repeated :args, :string, 1
      end


      class StringListReply
        repeated :reply, :string, 1
      end


      class TopPlaylistsRequest
        optional :username, :string, 1
        optional :count, :int32, 2
      end


      class TopPlaylistsReply
        repeated :uris, :string, 1
      end

    end
  end
end

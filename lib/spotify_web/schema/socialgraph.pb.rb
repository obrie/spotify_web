## Generated from socialgraph.proto for spotify.socialgraph.proto
require "beefcake"

module SpotifyWeb
  module Schema
    module Socialgraph

      module EventType
        FOLLOW = 1
        UNFOLLOW = 2
      end

      class SocialGraphEntity
        include Beefcake::Message
      end

      class SocialGraphRequest
        include Beefcake::Message
      end

      class SocialGraphReply
        include Beefcake::Message
      end

      class ChangeNotification
        include Beefcake::Message
      end

      class SocialGraphEntity
        optional :user_uri, :string, 1
        optional :artist_uri, :string, 2
        optional :followers_count, :int32, 3
        optional :following_count, :int32, 4
        optional :status, :int32, 5
        optional :is_following, :bool, 6
        optional :is_followed, :bool, 7
        optional :is_dismissed, :bool, 8
      end


      class SocialGraphRequest
        repeated :target_uris, :string, 1
        optional :source_uri, :string, 2
        optional :include_follower_count, :bool, 4
        optional :include_following_count, :bool, 5
      end


      class SocialGraphReply
        repeated :entities, SocialGraphEntity, 1
        optional :length, :int32, 2
      end


      class ChangeNotification
        optional :event_type, EventType, 1
        repeated :entities, SocialGraphEntity, 2
      end

    end
  end
end

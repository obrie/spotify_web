## Generated from bartender.proto for spotify.bartender.proto
require "beefcake"

module SpotifyWeb
  module Schema
    module Bartender

      module FallbackArtistType
        TYPE_UNKNOWN_FALLBACK = 0
        TYPE_FOLLOWED_ARTIST = 1
        TYPE_LOCAL_TRACK_ARTIST = 2
      end

      module RecentArtistType
        TYPE_UNKNOWN_RECENT_ARTIST = 3
        TYPE_LISTENED = 4
        TYPE_FOLLOWED = 5
        TYPE_LOCAL = 6
      end

      module StoryType
        TYPE_UNKNOWN_STORY = 0
        TYPE_RECOMMENDATION = 1
        TYPE_NEW_RELEASE = 2
        TYPE_SHARED_ITEM = 3
        TYPE_CREATED_ITEM = 4
        TYPE_SUBSCRIBED_TO_ITEM = 5
        TYPE_FOLLOWED_PROFILE = 6
        TYPE_SOCIAL_LISTEN = 7
        TYPE_RECENT_STREAM = 8
        TYPE_REPRISE = 9
        TYPE_CURRENT_FAVORITES = 10
        TYPE_RECENT_ARTIST = 11
        TYPE_BLAST_FROM_THE_PAST = 12
        TYPE_SOCIAL_LISTEN_LOW = 13
      end

      module ReasonType
        TYPE_UNKNOWN_REASON = 0
        TYPE_LISTENED_TO = 1
        TYPE_LISTENED_TO2 = 2
        TYPE_FOLLOW_USER = 3
        TYPE_FOLLOW_ARTIST = 4
        TYPE_POPULAR = 5
        TYPE_BFTP = 6
        TYPE_LOCAL_ARTIST = 7
        TYPE_ALGO = 8
      end

      module MetadataType
        TYPE_UNKNOWN_METADATA = 0
        TYPE_SPOTIFY_DATA = 1
        TYPE_REVIEW = 2
        TYPE_NEWS = 3
        TYPE_CONCERT = 4
        TYPE_PLAYLIST = 5
      end

      module ScoreType
        TYPE_UNKNOWN_SCORE = 0
        TYPE_FOLLOWER_COUNT = 1
        TYPE_STAR_RATING = 2
      end

      module RecLevel
        REC_LOW = 0
        REC_MID = 1
        REC_HIGH = 2
      end

      class StoryRequest
        include Beefcake::Message
      end

      class StoryList
        include Beefcake::Message
      end

      class Story
        include Beefcake::Message
      end

      class RichText
        include Beefcake::Message
      end

      class RichTextField
        include Beefcake::Message
      end

      class Reason
        include Beefcake::Message
      end

      class SpotifyLink
        include Beefcake::Message
      end

      class SpotifyAudioPreview
        include Beefcake::Message
      end

      class SpotifyImage
        include Beefcake::Message
      end

      class Metadata
        include Beefcake::Message
      end

      class ConcertData
        include Beefcake::Message
      end

      class Location
        include Beefcake::Message
      end

      class DiscoveredPlaylist
        include Beefcake::Message
      end

      class DiscoverNux
        include Beefcake::Message
      end

      class StoryWithReason
        include Beefcake::Message
      end

      class StoriesWithReasons
        include Beefcake::Message
      end

      class SocialReaction
        include Beefcake::Message
      end

      class UserList
        include Beefcake::Message
      end

      class StoryRequest
        optional :country, :string, 1
        optional :language, :string, 2
        optional :device, :string, 3
        optional :version, :int32, 4
        repeated :fallback_artist, :string, 5
        repeated :fallback_artist_type, FallbackArtistType, 6
        repeated :recent_artist, :string, 7
        repeated :recent_artist_type, RecentArtistType, 8
      end


      class StoryList
        repeated :stories, Story, 1
        optional :has_fallback, :bool, 12
        optional :is_last_page, :bool, 2
        optional :is_employee, :bool, 3
      end


      class Story
        optional :version, :int32, 1
        optional :story_id, :string, 2
        optional :type, StoryType, 3
        optional :reason, Reason, 4
        optional :recommended_item, SpotifyLink, 5
        optional :recommended_item_parent, SpotifyLink, 6
        repeated :hero_image, SpotifyImage, 8
        optional :metadata, Metadata, 9
        optional :reason_text, RichText, 10
        repeated :auxiliary_image, SpotifyImage, 11
        optional :reason_text_number, :int32, 12
      end


      class RichText
        optional :text, :string, 1
        repeated :fields, RichTextField, 2
      end


      class RichTextField
        optional :text, :string, 1
        optional :uri, :string, 2
        optional :url, :string, 3
        optional :bold, :bool, 4
        optional :italic, :bool, 5
        optional :underline, :bool, 6
      end


      class Reason
        optional :type, ReasonType, 1
        repeated :sample_criteria, SpotifyLink, 2
        optional :criteria_count, :int32, 3
        repeated :reason_type, ReasonType, 4
        repeated :date, :int32, 5
      end


      class SpotifyLink
        optional :uri, :string, 1
        optional :display_name, :string, 2
        optional :parent, SpotifyLink, 3
        repeated :preview, SpotifyAudioPreview, 6
      end


      class SpotifyAudioPreview
        optional :uri, :string, 1
        optional :file_id, :string, 2
      end


      class SpotifyImage
        optional :uri, :string, 1
        optional :file_id, :string, 2
        optional :width, :int32, 3
        optional :height, :int32, 4
      end


      class Metadata
        optional :id, :string, 1
        optional :app, :string, 2
        optional :type, MetadataType, 3
        optional :title, :string, 4
        optional :summary, :string, 5
        optional :favicon_url, :string, 6
        optional :external_url, :string, 7
        optional :internal_uri, :string, 8
        optional :dtpublished, :int32, 9
        optional :dtexpiry, :int32, 10
        optional :author, SpotifyLink, 11
        repeated :score, :int32, 12
        repeated :score_type, ScoreType, 13
        optional :concert_data, ConcertData, 14
        repeated :item_uri, :string, 15
        repeated :image, SpotifyImage, 16
        optional :bouncer_id, :string, 17
        repeated :related_uri, :string, 18
        optional :story_uuid, :string, 19
        optional :reactions, SocialReaction, 20
      end


      class ConcertData
        optional :dtstart, :int32, 1
        optional :dtend, :int32, 2
        optional :location, Location, 3
      end


      class Location
        optional :name, :string, 1
        optional :city, :string, 2
        optional :lat, :double, 3
        optional :lng, :double, 4
      end


      class DiscoveredPlaylist
        optional :uri, :string, 1
      end


      class DiscoverNux
        optional :seen, :int32, 1
      end


      class StoryWithReason
        optional :story, Story, 1
        optional :reason, Reason, 2
        repeated :track_uris, :string, 3
        optional :level, RecLevel, 4
      end


      class StoriesWithReasons
        repeated :stories, StoryWithReason, 1
      end


      class SocialReaction
        optional :id, :string, 1
        optional :likes, UserList, 2
        optional :streams, UserList, 3
        optional :reshares, UserList, 4
      end


      class UserList
        repeated :usernames, :string, 1
        optional :count, :int64, 2
        optional :include_requesting_user, :bool, 3
      end

    end
  end
end

## Generated from radio.proto for spotify.radio.proto
require "beefcake"

module SpotifyWeb
  module Schema
    module Radio

      class RadioRequest
        include Beefcake::Message
      end

      class MultiSeedRequest
        include Beefcake::Message
      end

      class Feedback
        include Beefcake::Message
      end

      class Tracks
        include Beefcake::Message
      end

      class Station
        include Beefcake::Message
      end

      class Rules
        include Beefcake::Message
      end

      class StationResponse
        include Beefcake::Message
      end

      class StationList
        include Beefcake::Message
      end

      class LikedPlaylist
        include Beefcake::Message
      end

      class RadioRequest
        repeated :uris, :string, 1
        optional :salt, :int32, 2
        optional :length, :int32, 4
        optional :stationId, :string, 5
        repeated :lastTracks, :string, 6
      end


      class MultiSeedRequest
        repeated :uris, :string, 1
      end


      class Feedback
        optional :uri, :string, 1
        optional :type, :string, 2
        optional :timestamp, :double, 3
      end


      class Tracks
        repeated :gids, :string, 1
        optional :source, :string, 2
        optional :identity, :string, 3
        repeated :tokens, :string, 4
        repeated :feedback, Feedback, 5
      end


      class Station
        optional :id, :string, 1
        optional :title, :string, 2
        optional :titleUri, :string, 3
        optional :subtitle, :string, 4
        optional :subtitleUri, :string, 5
        optional :imageUri, :string, 6
        optional :lastListen, :double, 7
        repeated :seeds, :string, 8
        optional :thumbsUp, :int32, 9
        optional :thumbsDown, :int32, 10
      end


      class Rules
        optional :js, :string, 1
      end


      class StationResponse
        optional :station, Station, 1
        repeated :feedback, Feedback, 2
      end


      class StationList
        repeated :stations, Station, 1
      end


      class LikedPlaylist
        optional :uri, :string, 1
      end

    end
  end
end

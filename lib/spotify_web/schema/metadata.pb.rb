## Generated from metadata.proto for spotify.metadata.proto
require "beefcake"

module SpotifyWeb
  module Schema
    module Metadata

      class TopTracks
        include Beefcake::Message
      end

      class ActivityPeriod
        include Beefcake::Message
      end

      class Artist
        include Beefcake::Message
      end

      class AlbumGroup
        include Beefcake::Message
      end

      class Date
        include Beefcake::Message
      end

      class Album
        include Beefcake::Message

        module Type
          ALBUM = 1
          SINGLE = 2
          COMPILATION = 3
        end
      end

      class Track
        include Beefcake::Message
      end

      class Image
        include Beefcake::Message

        module Size
          DEFAULT = 0
          SMALL = 1
          LARGE = 2
          XLARGE = 3
        end
      end

      class ImageGroup
        include Beefcake::Message
      end

      class Biography
        include Beefcake::Message
      end

      class Disc
        include Beefcake::Message
      end

      class Copyright
        include Beefcake::Message

        module Type
          P = 0
          C = 1
        end
      end

      class Restriction
        include Beefcake::Message

        module Catalogue
          AD = 0
          SUBSCRIPTION = 1
          SHUFFLE = 3
        end

        module Type
          STREAMING = 0
        end
      end

      class SalePeriod
        include Beefcake::Message
      end

      class ExternalId
        include Beefcake::Message
      end

      class AudioFile
        include Beefcake::Message

        module Format
          OGG_VORBIS_96 = 0
          OGG_VORBIS_160 = 1
          OGG_VORBIS_320 = 2
          MP3_256 = 3
          MP3_320 = 4
          MP3_160 = 5
          MP3_96 = 6
        end
      end

      class TopTracks
        optional :country, :string, 1
        repeated :track, Track, 2
      end


      class ActivityPeriod
        optional :start_year, :sint32, 1
        optional :end_year, :sint32, 2
        optional :decade, :sint32, 3
      end


      class Artist
        optional :gid, :bytes, 1
        optional :name, :string, 2
        optional :popularity, :sint32, 3
        repeated :top_track, TopTracks, 4
        repeated :album_group, AlbumGroup, 5
        repeated :single_group, AlbumGroup, 6
        repeated :compilation_group, AlbumGroup, 7
        repeated :appears_on_group, AlbumGroup, 8
        repeated :genre, :string, 9
        repeated :external_id, ExternalId, 10
        repeated :portrait, Image, 11
        repeated :biography, Biography, 12
        repeated :activity_period, ActivityPeriod, 13
        repeated :restriction, Restriction, 14
        repeated :related, Artist, 15
        optional :is_portrait_album_cover, :bool, 16
        optional :portrait_group, ImageGroup, 17
      end


      class AlbumGroup
        repeated :album, Album, 1
      end


      class Date
        optional :year, :sint32, 1
        optional :month, :sint32, 2
        optional :day, :sint32, 3
      end


      class Album
        optional :gid, :bytes, 1
        optional :name, :string, 2
        repeated :artist, Artist, 3
        optional :type, Album::Type, 4
        optional :label, :string, 5
        optional :date, Date, 6
        optional :popularity, :sint32, 7
        repeated :genre, :string, 8
        repeated :cover, Image, 9
        repeated :external_id, ExternalId, 10
        repeated :disc, Disc, 11
        repeated :review, :string, 12
        repeated :copyright, Copyright, 13
        repeated :restriction, Restriction, 14
        repeated :related, Album, 15
        repeated :sale_period, SalePeriod, 16
        optional :cover_group, ImageGroup, 17
      end


      class Track
        optional :gid, :bytes, 1
        optional :name, :string, 2
        optional :album, Album, 3
        repeated :artist, Artist, 4
        optional :number, :sint32, 5
        optional :disc_number, :sint32, 6
        optional :duration, :sint32, 7
        optional :popularity, :sint32, 8
        optional :explicit, :bool, 9
        repeated :external_id, ExternalId, 10
        repeated :restriction, Restriction, 11
        repeated :file, AudioFile, 12
        repeated :alternative, Track, 13
        repeated :sale_period, SalePeriod, 14
        repeated :preview, AudioFile, 15
      end


      class Image
        optional :file_id, :bytes, 1
        optional :size, Image::Size, 2
        optional :width, :sint32, 3
        optional :height, :sint32, 4
      end


      class ImageGroup
        repeated :image, Image, 1
      end


      class Biography
        optional :text, :string, 1
        repeated :portrait, Image, 2
        repeated :portrait_group, ImageGroup, 3
      end


      class Disc
        optional :number, :sint32, 1
        optional :name, :string, 2
        repeated :track, Track, 3
      end


      class Copyright
        optional :type, Copyright::Type, 1
        optional :text, :string, 2
      end


      class Restriction
        repeated :catalogue, Restriction::Catalogue, 1
        optional :countries_allowed, :string, 2
        optional :countries_forbidden, :string, 3
        optional :type, Restriction::Type, 4
      end


      class SalePeriod
        repeated :restriction, Restriction, 1
        optional :start, Date, 2
        optional :end, Date, 3
      end


      class ExternalId
        optional :type, :string, 1
        optional :id, :string, 2
      end


      class AudioFile
        optional :file_id, :bytes, 1
        optional :format, AudioFile::Format, 2
      end

    end
  end
end

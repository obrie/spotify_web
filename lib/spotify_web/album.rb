require 'spotify_web/resource'
require 'spotify_web/artist'
require 'spotify_web/restriction'
require 'spotify_web/schema/metadata.pb'

module SpotifyWeb
  # Represents an album on Spotify
  class Album < Resource
    self.metadata_schema = Schema::Metadata::Album

    def self.from_search_result(client, attributes) #:nodoc:
      attributes = attributes.merge(
        'artist' => [{
          :id => attributes['artist_id'],
          :name => attributes['artist_name']
        }],
        'restriction' => [attributes['restrictions']['restriction']].flatten.map do |restriction|
          {
            :countries_allowed => restriction['allowed'] && restriction['allowed'].split(',').join,
            :countries_forbidden => restriction['forbidden'] && restriction['forbidden'].split(',').join
          }
        end
      )

      super
    end

    # The title of the album
    # @return [String]
    attribute :title, :name

    # Info about the artist
    # @return [String]
    attribute :artist do |artist|
      Artist.new(client, artist[0].to_hash)
    end

    # The label that released the album
    # @return [String]
    attribute :label

    # The date the album was published on
    # @return [Date]
    attribute :published_on, :date do |date|
      Date.new(date.year, date.month || 1, date.day || 1)
    end

    # The relative popularity of this artist on Spotify
    # @return [Fixnum]
    attribute :popularity

    # The songs recorded on this album
    # @return [Array<SpotifyWeb::Song>]
    attribute :songs, :disc do |discs|
      songs = []
      discs.each do |disc|
        disc_songs = disc.track.map {|track| Song.new(client, track.to_hash)}
        songs.concat(disc_songs)
      end
      ResourceCollection.new(client, songs)
    end

    # The countries for which this album is permitted to be played
    # @return [Array<SpotifyWeb::Restriction>]
    attribute :restrictions, :restriction do |restrictions|
      restrictions.map {|restriction| Restriction.new(client, restriction.to_hash)}
    end

    # Whether this album is available to the user
    # @return [Boolean]
    def available?
      restrictions.all? {|restriction| restriction.permitted?}
    end
  end
end
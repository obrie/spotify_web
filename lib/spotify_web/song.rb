require 'spotify_web/resource'
require 'spotify_web/album'
require 'spotify_web/artist'
require 'spotify_web/schema/metadata.pb'

module SpotifyWeb
  # Represents a song on Spotify
  class Song < Resource
    self.metadata_schema = Schema::Metadata::Track
    self.resource_name = 'track'

    # The title of the song
    # @return [String]
    attribute :title, :name

    # Info about the artist
    # @return [SpotifyWeb::Artist]
    attribute :artist do |artist|
      Artist.new(client, artist[0].to_hash)
    end

    # Info about the album
    # @return [SpotifyWeb::Album]
    attribute :album do |album|
      Album.new(client, album.to_hash)
    end

    # The disc the song is located on within the album
    # @return [Fixnum]
    attribute :disc_number

    # The track number on the disc
    # @return [Fixnum]
    attribute :number

    # Number of seconds the song lasts
    # @return [Fixnum]
    attribute :length, :duration do |length|
      length / 1000
    end

    # The relative popularity of this song on Spotify
    # @return [Fixnum]
    attribute :popularity

    # The countries for which this song is permitted to be played
    # @return [Array<SpotifyWeb::Restriction>]
    attribute :restrictions, :restriction do |restrictions|
      restrictions.map {|restriction| Restriction.new(client, restriction.to_hash)}
    end

    # Whether this song is available to the user
    # @return [Boolean]
    def available?
      restrictions.all? {|restriction| restriction.permitted?}
    end
  end
end

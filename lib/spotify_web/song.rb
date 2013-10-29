require 'spotify_web/resource'
require 'spotify_web/album'
require 'spotify_web/artist'
require 'spotify_web/schema/bartender.pb'
require 'spotify_web/schema/metadata.pb'

module SpotifyWeb
  # Represents a song on Spotify
  class Song < Resource
    self.metadata_schema = Schema::Metadata::Track
    self.resource_name = 'track'

    def self.from_search_result(client, attributes) #:nodoc:
      attributes = attributes.merge(
        'name' => attributes['title'],
        'artist' => [{
          :id => attributes['artist_id'],
          :name => attributes['artist']
        }],
        'album' => {
          :id => attributes['album_id'],
          :name => attributes['album'],
          :artist => [{
            :id => attributes['album_artist_id'],
            :name => attributes['album_artist']
          }]
        },
        'number' => attributes['track_number'],
        'restriction' => [attributes['restrictions']['restriction']].flatten.map do |restriction|
          {
            :countries_allowed => restriction['allowed'] && restriction['allowed'].split(',').join,
            :countries_forbidden => restriction['forbidden'] && restriction['forbidden'].split(',').join
          }
        end
      )

      super
    end

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
    attribute :number do |value|
      value.to_i
    end

    # Number of seconds the song lasts
    # @return [Fixnum]
    attribute :length, :duration do |length|
      length / 1000
    end

    # The relative popularity of this song on Spotify
    # @return [Fixnum]
    attribute :popularity do |value|
      value.to_f
    end

    # The countries for which this song is permitted to be played
    # @return [Array<SpotifyWeb::Restriction>]
    attribute :restrictions, :restriction do |restrictions|
      restrictions.map {|restriction| Restriction.new(client, restriction.to_hash)}
    end

    # Whether this song is available to the user
    # @return [Boolean]
    def available?
      restrictions.all? {|restriction| restriction.permitted?(:country)}
    end

    # Looks up songs that are similar to the current one
    # @return [Array<SpotifyWeb::Song>]
    def similar
      response = api('request',
        :uri => "hm://similarity/suggest/#{uri_id}",
        :payload => Schema::Bartender::StoryRequest.new(
          :country => client.user.country,
          :language => client.user.language,
          :device => 'web'
        ),
        :response_schema => Schema::Bartender::StoryList
      )

      # Build songs based on recommendations
      songs = response['result'].stories.map do |story|
        song = story.recommended_item
        album = song.parent
        artist = album.parent

        Song.new(client,
          :uri => song.uri,
          :name => song.display_name,
          :album => {
            :uri => album.uri,
            :name => album.display_name,
            :artist => [{
              :uri => artist.uri,
              :name => artist.display_name
            }]
          },
          :artist => [{
            :uri => artist.uri,
            :name => artist.display_name
          }]
        )
      end

      ResourceCollection.new(client, songs)
    end
  end
end

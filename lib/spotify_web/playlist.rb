require 'spotify_web/resource'
require 'spotify_web/resource_collection'
require 'spotify_web/song'
require 'spotify_web/schema/mercury.pb'
require 'spotify_web/schema/playlist4.pb'

module SpotifyWeb
  # Represents a collection of songs
  class Playlist < Resource
    # The user this playlist is managed by
    # @return [SpotifyWeb::User]
    attribute :user, :load => false

    # The human-readable name for the playlist
    # @return [String]
    attribute :name

    # The songs that have been added to this playlist
    # @return [Array<SpotifyWeb::Song>]
    attribute :songs do |songs|
      ResourceCollection.new(client, songs.map {|song| Song.new(client, :uri => song.uri)})
    end

    def name #:nodoc:
      uri_id == 'starred' ? 'Starred' : @name
    end

    def uri_id #:nodoc:
      @uri_id ||= @uri ? @uri.split(':')[4] : super
    end

    # Loads the attributes for this playlist
    def load
      path = uri_id == 'starred' ? uri_id : "playlist/#{uri_id}"
      response = api('request',
        :uri => "hm://playlist/user/#{user.username}/#{path}?from=0&length=100",
        :response_schema => Schema::Playlist4::SelectedListContent
      )
      result = response['result']

      attributes = result.attributes.to_hash
      attributes[:songs] = result.contents.items
      self.attributes = attributes

      super
    end
  end
end

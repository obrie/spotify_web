require 'spotify_web/resource'

module SpotifyWeb
  # Represents an unauthorized user on Spotify
  class User < Resource
    # The username the user registered with on Spotify.
    # @return [String]
    attribute :username

    # Gets the playlists managed by the user.
    # 
    # @param [Hash] options The search options
    # @option options [Fixnum] :limit (100) The total number of playlists to get
    # @option options [Fixnum] :skip (0) The number of playlists to skip when loading the list
    # @option options [Boolean] :include_starred (false) Whether to include the playlist for songs the user starred
    # @return [Array<SpotifyWeb::Playlist>]
    # @example
    #   user.playlists    # => [#<SpotifyWeb::Playlist ...>, ...]
    def playlists(options = {})
      options = {:limit => 100, :skip => 0, :include_starred => false}.merge(options)

      response = api('request',
        :uri => "hm://playlist/user/#{username}/rootlist?from=#{options[:skip]}&length=#{options[:limit]}",
        :response_schema => Schema::Playlist4::SelectedListContent
      )

      playlists = response['result'].contents.items.map do |item|
        playlist(:uri => item.uri)
      end
      playlists << playlist(:starred) if options[:include_starred]

      ResourceCollection.new(client, playlists)
    end

    # Builds a playlist with the given attributes.
    # 
    # @param [Hash] attributes The attributes identifying the playlist
    # @return [SpotifyWeb::Playlist]
    # @example
    #   user.playlist(:starred)                                           # => #<SpotifyWeb::Playlist ...>
    #   user.playlist(:uri => "spotify:user:benzelano:playlist:starred")  # => #<SpotifyWeb::Playlist ...>
    def playlist(attributes = {})
      if attributes == :starred
        attributes = {:uri_id => 'starred'}
      end

      Playlist.new(client, attributes.merge(:user => self))
    end
  end
end

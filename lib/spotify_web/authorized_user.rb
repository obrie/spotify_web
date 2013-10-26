require 'spotify_web/playlist'
require 'spotify_web/resource_collection'
require 'spotify_web/user'
require 'spotify_web/schema/playlist4.pb'

module SpotifyWeb
  # Represents a user who has authorized with the Spotify service
  class AuthorizedUser < User
    # The username the user registered with on Spotify.
    # @return [String]
    attribute :username

    # The password associated with the username registered with on Spotify.
    # @return [String]
    attribute :password

    # Gets the authentication settings associated with this user for use with API
    # services.  This will log the user in via username / password if it's not already
    # set.
    # 
    # @return [String]
    # @raise [SpotifyWeb::Error] if the command fails
    def settings
      login unless @settings
      @settings
    end

    # Logs the user in using the associated e-mail address / password.  This will
    # generate a user id / auth token for authentication with the API services.
    # 
    # @api private
    # @return [true]
    # @raise [SpotifyWeb::Error] if the command fails
    def login
      # Look up the init options
      request = EventMachine::HttpRequest.new('https://play.spotify.com/')
      response = request.get(:head => {'User-Agent' => USER_AGENT})

      if response.response_header.successful?
        json = response.response.match(/Spotify\.Web\.Login\(document, (\{.+\}),[^\}]+\);/)[1]
        options = JSON.parse(json)

        # Authenticate the user
        request = EventMachine::HttpRequest.new('https://play.spotify.com/xhr/json/auth.php')
        response = request.post(
          :body => {
            :username => username,
            :password => password,
            :type => 'sp',
            :secret => options['csrftoken'],
            :trackingId => options['trackingId'],
            :landingURL => options['landingURL'],
            :referrer => options['referrer'],
            :cf => nil
          },
          :head => {'User-Agent' => USER_AGENT}
        )

        if response.response_header.successful?
          data = JSON.parse(response.response)

          if data['status'] == 'OK'
            @settings = data['config']
          else
            error = "Unable to authenticate (#{data['message']})"
          end
        else
          error = "Unable to authenticate (#{response.response_header.status})"
        end
      else
        error = "Landing page unavailable (#{response.response_header.status})"
      end

      raise(ConnectionError, error) if error

      true
    end

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

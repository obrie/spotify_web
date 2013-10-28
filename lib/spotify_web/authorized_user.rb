require 'spotify_web/playlist'
require 'spotify_web/resource_collection'
require 'spotify_web/user'
require 'spotify_web/schema/playlist4.pb'

module SpotifyWeb
  # Represents a user who has authorized with the Spotify service
  class AuthorizedUser < User
    # The password associated with the username registered with on Spotify.
    # @return [String]
    attribute :password, :load => false

    # The catalogue of songs this user is able to access
    # @return [String]
    attribute :catalogue do |value|
      value.to_sym
    end

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

    # The country this user belongs to and, therefore, the songs they have
    # access to
    # @return [String]
    def country
      settings['country']
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

    # Loads the attributes for this user
    def load
      response = api('sp/user_info')
      self.attributes = response['result']
      super
    end
  end
end

require 'fiber'
require 'execjs'

require 'spotify_web/album'
require 'spotify_web/artist'
require 'spotify_web/authorized_user'
require 'spotify_web/connection'
require 'spotify_web/error'
require 'spotify_web/event'
require 'spotify_web/handler'
require 'spotify_web/loggable'
require 'spotify_web/song'
require 'spotify_web/schema/mercury.pb'

module SpotifyWeb
  # Provides access to the Spotify Web API
  class Client
    include Assertions
    include Loggable

    # The interval with which to send keepalives
    KEEPALIVE_INTERVAL = 180

    # The current authorized user
    # @return [SpotifyWeb::User]
    attr_reader :user

    # The response timeout configured for the connection
    # @return [Fixnum]
    attr_reader :timeout
    
    # Creates a new client for communicating with Spotify with the given
    # username / password.
    # 
    # @param [String] username The username to authenticate with
    # @param [String] password The Spotify password associated with the username
    # @param [Hash] options The configuration options for the client
    # @option options [Fixnum] :timeout (10) The amount of seconds to allow to elapse for requests before timing out
    # @option options [Boolean] :reconnect (false) Whether to allow the client to automatically reconnect when disconnected either by Spotify or by the network
    # @option options [Fixnum] :reconnect_wait (5) The amount of seconds to wait before reconnecting
    # @raise [SpotifyWeb::Error] if an invalid option is specified
    # @yield Runs the given block within the context if the client (for DSL-type usage)
    def initialize(username, password, options = {}, &block)
      options = {
        :timeout => 10,
        :reconnect => false,
        :reconnect_wait => 5
      }.merge(options)
      assert_valid_keys(options, :timeout, :reconnect, :reconnect_wait)

      @user = AuthorizedUser.new(self, :username => username, :password => password)
      @event_handlers = {}
      @timeout = options[:timeout]
      @reconnect = options[:reconnect]
      @reconnect_wait = options[:reconnect_wait]

      # Setup default event handlers
      on(:work_requested) {|work| on_work_requested(work) }
      on(:session_ended)  { on_session_ended }

      reconnect_from(ConnectionError, APIError) do
        connect
      end

      instance_eval(&block) if block_given?
    end

    # Initiates a connection with the given url.  Once a connection is started,
    # this will also attempt to authenticate the user.
    # 
    # @api private
    # @note This will only open a new connection if the client isn't already connected to the given url
    # @param [String] url The url to open a connection to
    # @return [true]
    # @raise [SpotifyWeb::Error] if the connection cannot be opened
    def connect
      if !@connection || !@connection.connected?
        # Close any existing connection
        close

        # Create a new connection to the given url
        @connection = Connection.new(access_point_url, :timeout => timeout)
        @connection.handler = lambda {|data| trigger(data.delete('command'), data)}
        @connection.start

        # Wait for connection to open
        wait do |&resume|
          on(:session_started, :once => true) { resume.call }
        end

        # Send the user's credentials
        creds = user.settings['credentials'][0].split(':')
        message = [creds[0], creds[1], creds[2..-1] * ':']
        api('connect', message)

        wait do |&resume|
          on(:session_authenticated, :once => true) { resume.call }
        end

        start_keepalives
      end

      true
    end

    # Closes the current connection to Spotify if one was previously opened.
    # 
    # @return [true]
    def close(allow_reconnect = false)
      if @connection
        # Disable reconnects if specified
        reconnect = @reconnect
        @reconnect = reconnect && allow_reconnect

        # Clean up timers / connections
        @keepalive_timer.cancel if @keepalive_timer
        @keepalive_timer = nil
        @connection.close

        # Revert change to reconnect config once the final signal is received
        wait do |&resume|
          on(:session_ended, :once => true) { resume.call }
        end
        @reconnect = reconnect
      end
      
      true
    end

    # Runs the given API command.
    # 
    # @api private
    # @param [String] command The name of the command to execute
    # @param [Object] args The arguments to pass into the command
    # @return [Hash] The data returned from the Spotify service
    # @raise [SpotifyWeb::Error] if the connection is not open or the command fails to execute
    def api(command, args = nil)
      raise(ConnectionError, 'Connection is not open') unless @connection && @connection.connected?

      if command == 'request' && args.delete(:batch)
        batch(command, args) do |batch_command, batch_args|
          api(batch_command, batch_args)
        end
      else
        # Process this as a mercury request
        if command == 'request'
          response_schema = args.delete(:response_schema)
        end

        message_id = @connection.publish(command, args)

        # Wait until we get a response for the given message
        data = wait do |&resume|
          on(:response_received, :once => true, :if => {'id' => message_id}) {|data| resume.call(data)}
        end

        if command == 'request' && !data['error']
          # Parse the response bsed on the schema provided
          header, body = data['result']
          request = Schema::Mercury::MercuryRequest.decode(Base64.decode64(header))

          if (400..599).include?(request.status_code)
            data['error'] = "Failed response: #{request.status_code}"
          else
            data['result'] = response_schema.decode(Base64.decode64(body))
          end
        end

        if error = data['error']
          raise APIError, "Command \"#{command}\" failed with message: \"#{error}\""
        else
          data
        end
      end
    end

    # Starts the keepalive timer for ensure the connection remains open.
    # @api private
    def start_keepalives
      @keepalive_timer.cancel if @keepalive_timer
      @keepalive_timer = EM::Synchrony.add_periodic_timer(KEEPALIVE_INTERVAL) do
        SpotifyWeb.run { api('sp/echo', 'h') }
      end
    end

    # Gets the current authorized user or builds a new user bound to the given
    # user id.
    # 
    # @param [String] username The name of the user to build
    # @return [SpotifyWeb::User]
    # @example
    #   client.user               # => #<SpotifyWeb::User username="benze..." ...>
    #   client.user('johnd...')   # => #<SpotifyWeb::User username="johnd..." ...>
    def user(username = nil)
      username ? User.new(self, :username => username) : @user
    end

    # Builds a new song bound to the given id.
    # 
    # @param [String, Hash] attributes The id of the song to build or a hash of attributes
    # @return [SpotifyWeb::Song]
    # @example
    #   client.song("\x92\xA9...")   # => #<SpotifyWeb::Song id="\x92\xA9..." ...>
    def song(attributes)
      attributes = {:gid => attributes} unless attributes.is_a?(Hash)
      Song.new(self, attributes)
    end

    # Builds a new artist bound to the given id.
    # 
    # @param [String, Hash] attributes The id of the artist to build or a hash of attributes
    # @return [SpotifyWeb::Artist]
    # @example
    #   client.artist("\xC1\x8Fr...")   # => #<SpotifyWeb::Artist gid="\xC1\x8Fr..." ...>
    def artist(attributes)
      attributes = {:gid => attributes} unless attributes.is_a?(Hash)
      Artist.new(self, attributes)
    end

    # Builds a new album bound to the given id / attributes.
    # 
    # @param [String, Hash] attributes The id of the album to build or a hash of attributes
    # @return [SpotifyWeb::Album]
    # @example
    #   client.album("\x03\xC0...")   # => #<SpotifyWeb::Album id="\x03\xC0..." ...>
    def album(attributes)
      attributes = {:gid => attributes} unless attributes.is_a?(Hash)
      Album.new(self, attributes)
    end

    private
    # Determines the web socket url to connect to
    def access_point_url
      resolver = user.settings['aps']['resolver']
      query = {:client => "24:0:0:#{user.settings['version']}"}
      query[:site] = resolver['site'] if resolver['site']

      request = EventMachine::HttpRequest.new("http://#{resolver['hostname']}")
      response = request.get(:query => query, :head => {'User-Agent' => USER_AGENT})

      if response.response_header.successful?
        data = JSON.parse(response.response)
        data['ap_list'][0]
      else
        raise(ConnectionError, data['message'])
      end
    end

    # Runs a batch command within an API call
    def batch(command, options)
      # Update payload to be a batch
      requests = options[:payload].map do |attrs|
        attrs[:method] ||= 'GET'
        Schema::Mercury::MercuryRequest.new(attrs)
      end
      options[:payload] = Schema::Mercury::MercuryMultiGetRequest.new(:request => requests)

      # Track the schema
      response_schema = options[:response_schema]
      options[:response_schema] = Schema::Mercury::MercuryMultiGetReply

      response = yield(command, options)

      # Process each reply
      results = []
      response['result'].reply.each_with_index do |reply, index|
        if (400..599).include?(reply.status_code)
          request = requests[index]
          raise APIError, "Command \"#{command}\" for URI \"#{request.uri}\" failed with message: \"#{reply.status_code}\""
        else
          results << response_schema.decode(reply.body)
        end
      end

      response['result'] = results
      response
    end

    # Registers a handler to invoke when an event occurs in Spotify.
    # 
    # @param [Symbol] event The event to register a handler for
    # @param [Hash] options The configuration options for the handler
    # @option options [Hash] :if Specifies a set of key-value pairs that must be matched in the event data in order to run the handler
    # @option options [Boolean] :once (false) Whether to only run the handler once
    # @return [true]
    def on(event, options = {}, &block)
      event = event.to_sym
      @event_handlers[event] ||= []
      @event_handlers[event] << Handler.new(event, options, &block)
      true
    end

    # Triggers callback handlers for the given Spotify command.  This should
    # be invoked when responses are received for Spotify.
    # 
    # @note If the command is unknown, it will simply get skipped and not raise an exception
    # @param [Symbol] command The name of the command triggered.  This is typically the same name as the event.
    # @param [Array] args The arguments to be processed by the event
    # @return [true]
    def trigger(command, *args)
      command = command.to_sym if command

      if Event.command?(command)
        event = Event.new(self, command, args)
        handlers = @event_handlers[event.name] || []
        handlers.each do |handler|
          success = handler.run(event)
          handlers.delete(handler) if success && handler.once
        end
      end

      true
    end

    # Callback when Spotify has requested to evaluate javascript
    def on_work_requested(work)
      script = <<-eos
        this.reply = function() {
          this.result = Array.prototype.slice.call(arguments);
        };
        #{work['args'][0]}
      eos
      context = ExecJS.compile(script)
      result = context.eval('this.result')

      api('sp/work_done', result)
    end

    # Callback when the session has ended.  This will automatically reconnect if
    # allowed to do so.
    def on_session_ended
      @connection = nil

      # Automatically reconnect to the server if allowed
      if @reconnect
        reconnect_from(Exception) do
          connect
          trigger(:reconnected)
        end
      end
    end

    # Runs a given block and retries that block after a certain period of time
    # if any of the specified exceptions are raised.  Note that there is no
    # limit on the number of attempts to retry.
    def reconnect_from(*exceptions)
      begin
        yield
      rescue *exceptions => ex
        if @reconnect
          logger.debug "Connection failed: #{ex.message}"
          EM::Synchrony.sleep(@reconnect_wait)
          logger.debug 'Attempting to reconnect'
          retry
        else
          raise
        end
      end
    end

    # Pauses the current fiber until it is resumed with response data.  This
    # can only get resumed explicitly by the provided block.
    def wait(&block)
      fiber = Fiber.current

      # Resume the fiber when a response is received
      allow_resume = true
      block.call do |*args|
        fiber.resume(*args) if allow_resume
      end

      # Attempt to pause the fiber until a response is received
      begin
        Fiber.yield
      rescue FiberError => ex
        allow_resume = false
        raise Error, 'Spotify Web APIs cannot be called from root fiber; use SpotifyWeb.run { ... } instead'
      end
    end
  end
end

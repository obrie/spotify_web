require 'faye/websocket'
require 'em-http'
require 'json'

require 'spotify_web/assertions'
require 'spotify_web/loggable'
require 'spotify_web/schema/mercury.pb'

module SpotifyWeb
  # Represents the interface for sending and receiving data in Spotify
  # @api private
  class Connection
    include Assertions
    include Loggable

    # Maps method actions to their Spotify identifier
    METHODS = {'SUB' => 1, 'UNSUB' => 2}

    # The host that this connection is bound to
    # @return [String]
    attr_reader :host

    # The callback to run when a message is received from the underlying socket.
    # The data passed to the callback will always be a hash.
    # @return [Proc]
    attr_accessor :handler

    # Builds a new connection for sending / receiving data via the given host.
    # 
    # @note This will *not* open the connection -- #start must be explicitly called in order to do so.
    # @param [String] host The host to open a conection to
    # @param [Hash] options The connection options
    # @option options [Fixnum] :timeout The amount of time to allow to elapse for requests before timing out
    # @raise [ArgumentError] if an invalid option is specified
    def initialize(host, options = {})
      assert_valid_keys(options, :timeout)

      @host = host
      @message_id = 0
      @timeout = options[:timeout]
    end

    # Initiates the connection with Spotify
    # 
    # @return [true]
    def start
      uri = URI.parse("ws://#{host}")
      scheme = uri.port == 443 ? 'wss' : 'ws'
      @socket = Faye::WebSocket::Client.new("#{scheme}://#{uri.host}")
      @socket.onopen = lambda {|event| on_open(event)}
      @socket.onclose = lambda {|event| on_close(event)}
      @socket.onmessage = lambda {|event| on_message(event)}
      true
    end

    # Closes the connection (if one was previously opened)
    # 
    # @return [true]
    def close
      if @socket
        @socket.close

        # Spotify doesn't send the disconnect frame quickly, so the callback
        # gets run immediately
        EventMachine.add_timer(0.1) { on_close(nil) }
      end
      true
    end

    # Whether this connection's socket is currently open
    # 
    # @return [Boolean] +true+ if the connection is open, otherwise +false+
    def connected?
      @connected
    end

    # Publishes the given params to the underlying web socket.  The defaults
    # initially configured as part of the connection will also be included in
    # the message.
    # 
    # @param [Hash] params The parameters to include in the message sent
    # @return [Fixnum] The id of the message delivered
    def publish(command, options)
      if command == 'request'
        options = {:uri => '', :method => 'GET', :source => ''}.merge(options)
        options[:content_type] = 'vnd.spotify/mercury-mget-request' if options[:payload].is_a?(Schema::Mercury::MercuryMultiGetRequest)
        payload = options.delete(:payload)

        # Generate arguments for the request
        args = [
          METHODS[options[:method]] || 0,
          Base64.encode64(Schema::Mercury::MercuryRequest.new(options).encode)
        ]
        args << Base64.encode64(payload.encode) if payload

        # Update the command to what Spotify expects
        command = 'sp/hm_b64'
      else
        args = options
      end

      message = {
        :id => next_message_id,
        :name => command,
        :args => args || []
      }

      logger.debug "Message sent: #{message.inspect}"
      @socket.send(message.to_json)

      # Add timeout handler
      EventMachine.add_timer(@timeout) do
        dispatch('id' => message[:id], 'command' => 'response_received', 'error' => 'timed out')
      end if @timeout

      message[:id]
    end

    private
    # Runs the configured handler with the given message
    def dispatch(message)
      SpotifyWeb.run { @handler.call(message) } if @handler
    end

    # Callback when the socket is opened.
    def on_open(event)
      logger.debug 'Socket opened'
      @connected = true
      dispatch('command' => 'session_started')
    end

    # Callback when the socket is closed.  This will mark the connection as no
    # longer connected.
    def on_close(event)
      logger.debug 'Socket closed'
      @connected = false
      @socket = nil
      dispatch('command' => 'session_ended')
    end

    # Callback when a message has been received from the remote server on the
    # open socket.
    def on_message(event)
      message = JSON.parse(event.data)

      if message['id']
        message['command'] = 'response_received'
      elsif message['message']
        command, *args = *message['message']
        message = {'command' => command, 'args' => args}
      end

      logger.debug "Message received: #{message.inspect}"
      dispatch(message)
    end

    # Calculates what the next message id should be sent to Spotify
    def next_message_id
      @message_id += 1
    end
  end
end

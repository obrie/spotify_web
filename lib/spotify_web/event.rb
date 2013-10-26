module SpotifyWeb
  # Provides access to all of the events that get triggered by incoming messages
  # from the Spotify Web API
  # @api private
  class Event
    class << self
      # Maps Spotify command => event name
      # @return [Hash<String, String>]
      attr_reader :commands

      # Defines a new event that maps to the given Spotify command.  The
      # block defines how to typecast the data that is received from Spotify.
      # 
      # @param [String] name The name of the event exposed to the rest of the library
      # @param [String] command The Spotify command that this event name maps to
      # @yield [data] Gives the data to typecast to the block
      # @yieldparam [Hash] data The data received from Spotify
      # @yieldreturn The typecasted data that should be passed into any handlers bound to the event
      # @return [nil]
      def handle(name, command = name, &block)
        block ||= lambda { [args] }
        commands[command] = name

        define_method("typecast_#{command}_event", &block)
        protected :"typecast_#{command}_event"
      end

      # Determines whether the given command is handled.
      # 
      # @param [String] command The command to check for the existence of
      # @return [Boolean] +true+ if the command exists, otherwise +false+
      def command?(command)
        commands.include?(command)
      end
    end

    @commands = {}

    # The client's connection has opened
    handle :session_started

    # The client's connection has closed
    handle :session_ended

    # The user is successfully logged in
    handle :session_authenticated, :login_complete

    # The client re-connected after previously being disconnected
    handle :reconnected

    # A response was receivied from a prior command sent to Spotify
    handle :response_received do
      data
    end

    # A request was made to evaluate javascript on the client
    handle :work_requested, :do_work do
      data
    end

    # The name of the event that was triggered
    # @return [String]
    attr_reader :name

    # The raw arguments list from the event
    # @return [Array<Object>]
    attr_reader :args

    # The raw hash of data parsed from the event
    # @return [Hash<String, Object>]
    attr_reader :data

    # The typecasted results args parsed from the event
    # @return [Array<Array<Object>>]
    attr_reader :results

    # Creates a new event triggered with the given data
    # 
    # @param [SpotifyWeb::Client] client The client that this event is bound to
    # @param [Symbol] command The name of the command that fired the event
    # @param [Array] args The raw argument data from the event
    def initialize(client, command, args)
      @client = client
      @args = args
      @data = args[0]
      @name = self.class.commands[command]
      @results = __send__("typecast_#{command}_event")
      @results = [[@results].compact] unless @results.is_a?(Array)
    end

    private
    # The client that all APIs filter through
    attr_reader :client
  end
end

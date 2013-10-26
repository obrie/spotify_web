require 'logger'
require 'em-synchrony'
require 'em-synchrony/em-http'

# Spotify Web API for Ruby
module SpotifyWeb
  # The user agent for Spotify access
  USER_AGENT = 'node-spotify-web (Chrome/13.37 compatible-ish)'

  autoload :Client, 'spotify_web/client'
  autoload :Schema, 'spotify_web/schema'

  class << self
    # The logger to use for all Spotify messages.  By default, everything is
    # logged to STDOUT.
    # @return [Logger]
    attr_accessor :logger

    # Whether this is going to be used in an interactive console such as IRB.
    # If this is enabled then EventMachine will run in a separate thread.  This
    # will allow IRB to continue to actually be interactive.
    # 
    # @note You must continue to run all commands on a client through SpotifyWeb#run.
    # @example
    #   require 'spotify_web'
    #   
    #   SpotifyWeb.interactive
    #   SpotifyWeb.run do
    #     @client = SpotifyWeb::Client.new(...)
    #     @client.start
    #   end
    #   
    #   # ...later on after the connection has started and you want to interact with it
    #   SpotifyWeb.run do
    #     @client.user.playlists
    #     # ...
    #   end
    def interactive
      Thread.new { EM.run }.abort_on_exception = true
    end

    # Sets up the proper EventMachine reactor / Fiber to run commands against a
    # client.  If this is not in interactive mode, then the block won't return
    # until the EventMachine reactor is stopped.
    # 
    # @note If you're already running within an EventMachine reactor *and* a
    # Fiber, then there's no need to call this method prior to interacting with
    # a SpotifyWeb::Client instance.
    # @example
    #   # Non-interactive, not in reactor / fiber
    #   SpotifyWeb.run do
    #     client = SpotifyWeb::Client.new(...)
    #     client.playlists
    #     # ...
    #   end
    #   
    #   # Interactive, not in reactor / fiber
    #   SpotifyWeb.interactive
    #   SpotifyWeb.run do
    #     @client = ...
    #   end
    #   SpotifyWeb.run do
    #     @client.playlists
    #     # ...
    #   end
    #   
    #   # Non-interactive, already in reactor / fiber
    #   client = SpotifyWeb::Client(...)
    #   client.playlists
    # 
    # @example DSL
    #   # Takes the same arguments as SpotifyWeb::Client
    #   SpotifyWeb.run(USERNAME, PASSWORD) do
    #     user.playlists
    #   end
    # 
    # == Exception handling
    # 
    # Any exceptions that occur within the block will be automatically caught
    # and logged.  This prevents the EventMachine reactor from dying.
    def run(*args, &block)
      if EM.reactor_running?
        EM.next_tick do
          EM.synchrony do
            begin
              if args.any?
                # Run the block within a client
                Client.new(*args, &block)
              else
                # Just run the block within a fiber
                block.call
              end
            rescue StandardError => ex
              logger.error(([ex.message] + ex.backtrace) * "\n")
            end
          end
        end
      else
        EM.synchrony { run(*args, &block) }
      end
    end
  end

  @logger = Logger.new(STDOUT)
end
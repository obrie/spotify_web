module SpotifyWeb
  # Provides a set of helper methods for logging
  # @api private
  module Loggable
    private
    # Delegates access to the logger to SpotifyWeb.logger
    # 
    # @return [Logger] The logger configured for this library
    def logger
      SpotifyWeb.logger
    end
  end
end

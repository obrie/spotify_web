module SpotifyWeb
  # Represents an error within the library
  class Error < StandardError
  end
  
  # Represents an error that occurred while connecting to the Spotify Web API
  class ConnectionError < Error
  end
  
  # Represents an error that occurred while interacting with the Spotify Web API
  class APIError < Error
  end
end

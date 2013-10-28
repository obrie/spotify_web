require 'spotify_web/resource'

module SpotifyWeb
  # Represents a country-based restriction on Spotify data
  class Restriction < Resource
    # The countries allowed to access the data
    # @return [String]
    attribute :countries_allowed do |countries|
      countries.scan(/.{2}/)
    end

    # The countries forbidden to access the data
    # @return [String]
    attribute :countries_forbidden do |countries|
      countries.scan(/.{2}/)
    end

    # Whether the user is permitted to access data based on this restriction
    # @return [Boolean]
    def permitted?
      country = client.user.country

      if countries_allowed
        countries_allowed.include?(country)
      elsif countries_forbidden
        !countries_forbidden.include?(country)
      else
        true
      end
    end
  end
end
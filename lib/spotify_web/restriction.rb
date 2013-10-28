require 'spotify_web/resource'

module SpotifyWeb
  # Represents a country-based restriction on Spotify data
  class Restriction < Resource
    CATALOGUE_IDS = {
      Schema::Metadata::Restriction::Catalogue::AD => [:free],
      Schema::Metadata::Restriction::Catalogue::SUBSCRIPTION => [:premium, :unlimited]
    }

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

    # The catalogues this song is a member of. This determines which accounts
    # can play which songs
    # @return [Array<Symbol>]
    attribute :catalogues, :catalogue do |catalogues|
      catalogues.map {|id| CATALOGUE_IDS[id]}.compact.flatten
    end

    # Whether the user is permitted to access data based on this restriction
    # 
    # @param [String] type [:all] The permission to check
    # @return [Boolean]
    def permitted?(type = :all)
      assert_valid_values(type, :all, :country, :catalogue)

      if type == :all
        permissions.values.all?
      else
        permissions[type]
      end
    end

    private
    # The list of permissions for country / catalogue
    def permissions
      {:country => country_permitted?, :catalogue => catalogue_permitted?}
    end

    # Whether the user is allowed to access data from this catalog.  Users
    # *must* be premium users in order to access a catalogue.
    def catalogue_permitted?
      client.user.catalogue == :premium && catalogues.include?(client.user.catalogue)
    end

    # Whether tue user is allowed to access data from within their country
    def country_permitted?
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
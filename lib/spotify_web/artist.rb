require 'spotify_web/resource'
require 'spotify_web/schema/metadata.pb'

module SpotifyWeb
  # Represents an artist on Spotify
  class Artist < Resource
    self.metadata_schema = Schema::Metadata::Artist

    # The title of the artist
    # @return [String]
    attribute :name

    # The relative popularity of this artist on Spotify
    # @return [Fixnum]
    attribute :popularity

    # The top songs for this artist
    # @return [Array<SpotifyWeb::Song>]
    attribute :top_songs, :top_track do |groups|
      group = groups.detect {|group| group.country == 'US'}
      songs = group.track.map {|song| Song.new(client, song.to_hash)}
      ResourceCollection.new(client, songs)
    end

    # The albums this artist has recorded
    # @return [Array<SpotifyWeb::Album>]
    attribute :albums, :album_group do |groups|
      # Track all available albums
      albums = []
      groups.each do |group|
        group_albums = []
        group.album.each do |album|
          album = Album.new(client, album.to_hash)
          group_albums << album if album.available?
        end

        albums.concat(group_albums)
      end

      # Load the data to completely determine what albums to give back
      albums = ResourceCollection.new(client, albums)
      albums.load

      # Reject duplicate titles
      albums_by_title = albums.inject({}) do |result, album|
        result[album.title] = album
        result
      end
      albums.reject! {|album| albums_by_title[album.title] != album}

      albums
    end
  end
end
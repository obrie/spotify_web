#!/usr/bin/env ruby
# List all songs in the user's playlists
require 'spotify_web'

USERNAME = ENV['USERNAME']  # 'xxxxx'
PASSWORD = ENV['PASSWORD']  # 'xxxxx'

SpotifyWeb.run(EMAIL, PASSWORD) do
  user.playlists.each do |playlist|
    playlist.songs.each do |song|
      puts "[#{playlist.name}] #{song.artist.name} - #{song.title}"
    end
  end
end

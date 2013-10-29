namespace :spotify do
  desc 'Builds the schemas based on the current Spotify definitions'
  task :build_schemas do
    $:.unshift(File.dirname(__FILE__) + '/..')
    require 'spotify_web'

    SpotifyWeb::Schema.build_all
  end
end
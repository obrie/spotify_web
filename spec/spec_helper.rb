$LOAD_PATH << File.expand_path("../../lib", __FILE__)

require 'spotify_web'

RSpec.configure do |config|
  config.order = 'random'
end

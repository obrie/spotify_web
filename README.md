# spotify_web [![Build Status](https://secure.travis-ci.org/obrie/spotify_web.png "Build Status")](http://travis-ci.org/obrie/spotify_web) [![Dependency Status](https://gemnasium.com/obrie/spotify_web.png "Dependency Status")](https://gemnasium.com/obrie/spotify_web)

*spotify_web* is an evented Spotify Web API for Ruby.

## Resources

API

* http://rdoc.info/github/obrie/spotify_web/master/frames

Bugs

* http://github.com/obrie/spotify_web/issues

Development

* http://github.com/obrie/spotify_web

Testing

* http://travis-ci.org/obrie/spotify_web

Source

* git://github.com/obrie/spotify_web.git

## Description

SpotifyWeb makes it dead-simple to interact with the unofficial Spotify Web API.
It is an opinionated library that attempts to hide the various complexities of
the Spotify API by providing a clean design around how data is accessed and
organized.

This project was built from the ground-up by Rubyists for Rubyists.  While prior
projects in other languages were used for guidance on some of the implementation,
the design is meant to take advantage of the various features offered by Ruby 1.9+.

At a high level, this project features:

* Evented, non-blocking I/O
* Fiber-aware, untangled callbacks
* Interactive console support
* Clean, object-oriented APIs
* Detailed API documentation
* Lazy-loaded attributes
* Auto-reconnects for bots
* Consistent API / attribute naming schemes
* DSL syntax support

SpotifyWeb features include access to / management of:

* User playlists
* Artist / Album / Song metadata
* Others to be added...

Examples of the usage patterns for some of the above features are shown below.
You can find much more detailed documentation in the actual API.

## Usage

### Example

Below is an example of some of the features offered by this API:
  
```ruby
require 'spotify_web'

USERNAME = ENV['USERNAME']
PASSWORD = ENV['PASSWORD']

SpotifyWeb.run do
  client = SpotifyWeb::Client.new(USERNAME, PASSWORD)
  
  # Events
  client.on :session_authenticated do
    # ...
  end

  # Authorized user interactions
  user = client.user                                # => #<SpotifyWeb::AuthorizedUser @username="benzelano" ...>

  # Playlist interaction
  user.playlists                                    # => [#<SpotifyWeb::Playlist @uri="hm://playlist/user/..." ...>, ...]
  user.playlist(:starred).songs.each do
    song.artist.name
    song.artist.albums
    song.artist.top_songs
    song.title
    song.album.published_on
  end
end
```

The example above is just a very, very small subset of the possible things you
can do with spotify_web.  For a *complete* list, see the API documentation, especially:

* [SpotifyWeb::Album](http://rdoc.info/github/obrie/spotify_web/master/frames/SpotifyWeb/Album)
* [SpotifyWeb::Artist](http://rdoc.info/github/obrie/spotify_web/master/frames/SpotifyWeb/Artist)
* [SpotifyWeb::AuthorizedUser](http://rdoc.info/github/obrie/spotify_web/master/frames/SpotifyWeb/AuthorizedUser)
* [SpotifyWeb::Client](http://rdoc.info/github/obrie/spotify_web/master/frames/SpotifyWeb/Client)
* [SpotifyWeb::Playlist](http://rdoc.info/github/obrie/spotify_web/master/frames/SpotifyWeb/Playlist)
* [SpotifyWeb::Song](http://rdoc.info/github/obrie/spotify_web/master/frames/SpotifyWeb/Song)

For additional examples, see the [examples](https://github.com/obrie/spotify_web/tree/master/examples)
directory in the repository.

## Additional Topics

### Differences with existing libraries

So you may be asking "Why re-build this in Ruby when you have a stable
Javascript project?"  There are two main reasons.  First, one of the projects
that need this was in Ruby and preferred to have a Ruby interface to the APi.
Second, I felt that many of the high-level details highlighted in the
Description section of this document were missing in existing libraries.

Some of those details include untangled callbacks, object-oriented APIs,
external API consistency, auto lazy-loading, etc.  This library also strives
to be a complete implementation and easy to use / play around with.

By no means does this discredit the significance and usefulness of the other
libraries -- they all have a user and all provided the foundation necessary
to build out this project.

### Authentication

spotify_web authenticates users with the username and password associated with
their account.  For example:

```ruby
SpotifyWeb.run do
  client = SpotifyWeb::Client.new(USERNAME, PASSWORD)
  # ...
end
```

### Interactive Console

Typically it's difficult to debug or run simple tests within IRB when using
[EventMachine](http://rubyeventmachine.com/).  However, spotify_web provides a
few simple ways to do this so that you can play around with the API interactively.

For example:

```ruby
1.9.3-p286 :001 > require 'spotify_web'
=> true
1.9.3-p286 :002 > SpotifyWeb.interactive
=> true
1.9.3-p286 :003 > client = nil
=> nil
1.9.3-p286 :004 > SpotifyWeb.run do
1.9.3-p286 :005 >   client = SpotifyWeb::Client.new(USERAME, PASSWORD)
1.9.3-p286 :006 > end
=> nil

# later on...
1.9.3-p286 :008 > SpotifyWeb.run { puts client.playlists.inspect }
=> nil
[#<SpotifyWeb::Playlist:0xa0c7da8 @uri="...">, #<SpotifyWeb::Playlist:0xa0c7bf0 @uri="...">]
```

In this example, an instance of `SpotifyWeb::Client` is created and tracked in
the console.  Later on, we can then run a command on that client by evaluating
it within a `SpotifyWeb.run` block.

### DSL syntax

spotify_web has basic support for a DSL language in order to simplify some of the
scripts you may be writing.  The DSL is essentially made available by executing
blocks within the context of a `SpotifyWeb::Client` instance.

There are two ways to do this:

```ruby
# Using the SpotifyWeb.run shortcut:

SpotifyWeb.run(USERNAME, PASSWORD) do
  playlists.each do
    # ...
  end
  on :session_authenticated do
    # ...
  end
end

# Passing a block into SpotifyWeb::Client:

SpotifyWeb.run do
  SpotifyWeb::Client.new(USERNAME, PASSWORD) do
    playlists.each do
      # ...
    end
    on :session_authenticated do
      # ...
    end
  end
end
```

*Note* that you will likely not want to use the first example (using the
`SpotifyWeb.run` shortcut) when running in the context of a web request in a
web server, simply because it will start a new Fiber.

The equivalent, non-DSL example looks like so:

```ruby
SpotifyWeb.run do
  client = SpotifyWeb::Client.new(USERNAME, PASSWORD)
  client.playlists.each do
    # ...
  end
  client.on :session_authenticated do
    # ...
  end
end
```

Notice that in this example the syntax is essentially the same except that we're
one level out and need to interact directly with the `SpotifyWeb::Client`
instance itself.

## Deployment

### Web Server Usage

You'll notice that in many places in the documentation, `SpotifyWeb.run` is
used to start running a block of code for interacting with the API.  This is
done in order to ensure that the block of code is being run with a running
EventMachine and within a non-root Fiber.

When spotify_web is being used as part of a web server or anything else that's
already running EventMachine and already executing code within a non-root Fiber
(such as the rainbows web server) you *should not* using the `run` API.  Instead
you can just run your block like normal:

```ruby
client = SpotifyWeb::Client.new(USERNAME, PASSWORD)
playlists = client.user.playlists
# ...
```

### Persistent Usage

If you're using spotify_web for persistence, long-lived usage, the primary thing to keep
in mind is how to handle connection loss.  This can occur as a result of a lost
internet connection or even just Spotify forcefully closing a socket for unknown
reasons.  To protect against this, you can configure spotify_web to automatically
keep attempting to re-open a connection when it's been closed.

For example:

```ruby
SpotifyWeb.run(USERNAME, PASSWORD, :reconnect => true, :reconnect_wait => 60) do
  # ...
end
```

In this example, spotify_web will automatically attempt to reconnect if the socket
is ever closed by reasons other than you closing it yourself.  However, rather
than constantly trying to hit Spotify's servers you can configure a reconnect
wait timeout that will cause spotify_web to wait a certain number of seconds before
attempting to open a connection.  This will continue to happen until the connection
is successful.

## Testing

To run the core test suite:

```bash
bundle install
bundle exec rspec
```

## Caveats

The following caveats should be noted when using spotify_web:

* Since this library uses EventMachine / Fibers it will only be compatible with
  web servers that support those technologies.  Examples of such web servers include:
  * [Thin](http://code.macournoyer.com/thin/)
  * [Rainbows](http://rainbows.rubyforge.org/)
  * [Goliath](http://postrank-labs.github.com/goliath/)
* This is *not* an official library and so Spotify may make changes to its API
  that causes this to break.  Hopefully we can build a community that can quickly
  react and provide fixes to those changes.

## Things to do

* Add test coverage
* 100% complete Spotify Web API implementation

## Contributions

The largest contribution for this library is the reference material provided by
Nathan Rajlich's [node-spotify-web](https://github.com/TooTallNate/node-spotify-web)
and Hexxeh's [spotify-websocket-api](github.com/Hexxeh/spotify-websocket-api) libraries.
They provided much of the legwork to get understand how Spotify's Web API works and
made it much easier to bring a Ruby perspective to it.

## Dependencies

* Ruby 1.9.3 or later
* [beefcake](https://github.com/protobuf-ruby/beefcake)
* [em-http-request](https://github.com/igrigorik/em-http-request)
* [em-synchrony](https://github.com/igrigorik/em-synchrony)
* [execjs](https://github.com/sstephenson/execjs)
* [faye-websocket-ruby](https://github.com/faye/faye-websocket-ruby)
* [radix](https://github.com/rubyworks/radix)

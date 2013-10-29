require 'net/http'
require 'json'
require 'rexml/document'

module SpotifyWeb
  module Schema
    # The services that are used
    SERVICES = %w(
      mercury
      metadata
      playlist4changes
      playlist4content
      playlist4issues
      playlist4meta
      playlist4ops
      radio
      toplist
    )

    SERVICE_URLS = {
      'socialgraph' => 'https://play.spotify.edgekey.net/apps/follow/1995/proto/socialgraphV2.proto',
      'bartender' => 'https://play.spotify.edgekey.net/apps/discover/1838/proto/bartender.proto'
    }

    class << self
      # Rebuilds all of the Beecake::Message schema definitions in Spotify.
      # Note that this schema is not always kept up-to-date in Spotify --
      # and can sometimes include parser errors.  As a result, there may be
      # some manual changes that need to be made once the build is complete.
      def build_all
        # Prepare target directories
        proto_dir = File.join(File.dirname(__FILE__), '../../proto')
        schema_dir = File.join(File.dirname(__FILE__), 'schema')
        Dir.mkdir(proto_dir) unless Dir.exists?(proto_dir)

        # Build the proto files
        packages.each do |name, package|
          File.open("#{proto_dir}/#{name}.proto", 'w') {|f| f << package[:content]}
        end

        # Convert each proto file to a Beefcake message
        packages.each do |name, package|
          system(
            {'BEEFCAKE_NAMESPACE' => package[:namespace]},
            "protoc --beefcake_out #{schema_dir} -I #{proto_dir} #{proto_dir}/#{name}.proto"
          )
        end
      end

      # Generates the Protocol Buffer packages based on the current list of
      # Spotify services.  This will merge certain services together under
      # the same package if they have the same namespace.
      def packages
        packages = {}

        services.values.each do |service|
          namespace = 'SpotifyWeb::Schema'
          if match = service[:content].match(/package spotify\.(.+)\.proto;/)
            name = match[1]
            namespace << '::' + name.split('.').map {|part| part.capitalize} * '::'
          else
            name = 'core'
          end

          if package = packages[name]
            # Package already exists: just append the message definitions
            content = service[:content]
            content = content[content.index('message')..-1]
            package[:content] += "\n#{content}"
          else
            # Create a new package with the entire definition
            packages[name] = {:name => name, :namespace => namespace, :content => service[:content]}
          end
        end

        packages
      end

      # Gets the collection of services defined in Spotify and the resource
      # definitions associated with them
      def services
        services = {}

        # Get the current schema
        request = Net::HTTP::Get.new(data_url)
        request['User-Agent'] = SpotifyWeb::USER_AGENT
        uri = URI(data_url)
        response = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
          http.request(request)
        end

        # Parse each service definition
        doc = REXML::Document.new(response.body)
        doc.elements.each('services') do |root|
          root.elements.each do |service|
            name = service.name
            if SERVICES.include?(name)
              content = service.text.strip
              services[name] = {:name => name, :content => content}
            end
          end
        end

        # Parse additional services
        SERVICE_URLS.each do |service, url|
          request = Net::HTTP::Get.new(url)
          request['User-Agent'] = SpotifyWeb::USER_AGENT
          uri = URI(url)
          response = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
            http.request(request)
          end

          services[service] = {:name => service, :content => response.body}
        end

        services
      end

      # Looks up the url representing the current schema for all Spotify services
      def data_url
        # Grab the login init options
        request = Net::HTTP::Get.new('https://play.spotify.com')
        request['User-Agent'] = SpotifyWeb::USER_AGENT
        response = Net::HTTP.start('play.spotify.com', 443, :use_ssl => true) do |http|
          http.request(request)
        end

        json = response.body.match(/Spotify\.Web\.Login\(document, (\{.+\}),[^\}]+\);/)[1]
        options = JSON.parse(json)

        "#{options['corejs']['protoSchemasLocation']}data.xml"
      end
    end
  end
end
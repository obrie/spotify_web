require 'pp'
require 'radix'
require 'spotify_web/assertions'
require 'spotify_web/error'

module SpotifyWeb
  # Represents an object that's been created using content from Spotify. This
  # encapsulates responsibilities such as reading and writing attributes.
  class Resource
    include Assertions

    class << self
      include Assertions

      # Defines a new Spotify attribute on this class.  By default, the name
      # of the attribute is assumed to be the same name that Spotify specifies
      # in its API.  If the names are different, this can be overridden on a
      # per-attribute basis.
      # 
      # @api private
      # @param [String] name The name for the attribute
      # @param [Hash] options The configuration options
      # @option options [Boolean] :load (true) Whether the resource should be loaded remotely from Spotify in order to access the attribute
      # @raise [ArgumentError] if an invalid option is specified
      # @example
      #   # Define a "name" attribute that maps to a Spotify "name" attribute
      #   attribute :name
      #   
      #   # Define an "id" attribute that maps to a Spotify "_id" attribute
      #   attribute :id, :_id
      #   
      #   # Define an "user_id" attribute that maps to both a Spotify "user_id" and "userid" attribute
      #   attribute :user_id, :user_id, :userid
      #   
      #   # Define a "time" attribute that maps to a Spotify "time" attribute
      #   # and converts the value to a Time object
      #   attribute :time do |value|
      #     Time.at(value)
      #   end
      #   
      #   # Define a "created_at" attribute that maps to a Spotify "time" attribute
      #   # and converts the value to a Time object
      #   attribute :created_at, :time do |value|
      #     Time.at(value)
      #   end
      #   
      #   # Define a "songs" attribute that does *not* get loaded from Spotify
      #   # when accessed
      #   attribute :songs, :load => false
      # 
      # @!macro [attach] attribute
      #   @!attribute [r] $1
      def attribute(name, *spotify_names, &block)
        options = spotify_names.last.is_a?(Hash) ? spotify_names.pop : {}
        assert_valid_keys(options, :load)
        options = {:load => true}.merge(options)

        # Reader
        define_method(name) do
          load if instance_variable_get("@#{name}").nil? && !loaded? && options[:load]
          instance_variable_get("@#{name}")
        end

        # Query
        define_method("#{name}?") do
          !!__send__(name)
        end

        # Typecasting
        block ||= lambda do |value|
          value.force_encoding('UTF-8') if value.is_a?(String)
          value
        end
        define_method("typecast_#{name}", &block)
        protected :"typecast_#{name}"

        # Attribute name conversion
        spotify_names = [name] if spotify_names.empty?
        spotify_names.each do |spotify_name|
          define_method("#{spotify_name}=") do |value|
            instance_variable_set("@#{name}", value.nil? ? nil : __send__("typecast_#{name}", value))
          end
          protected :"#{spotify_name}="
        end
      end

      # The Spotify type name for this resouce
      # @return [String]
      attr_accessor :resource_name

      # The metadata schema to use for loading data for this resource
      # @return [Class]
      attr_accessor :metadata_schema

      # Provides a default resource name if one isn't specified
      # @return [String]
      def resource_name
        @resource_name ||= begin
          result = name.split('::').last.downcase
          result.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
          result.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
          result
        end
      end
    end

    # The characters to encoding / decoding in base62
    BASE62_CHARS = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a

    # The unique id for this resource on Spotify
    # "e1987c10dbc34f4d8be1b11ddfd6bb31"
    # @return [String]
    attribute :id, :load => false

    # The global unique id for this resource on Spotify
    # "\xE1\x98|\x10\xDB\xC3OM\x8B\xE1\xB1\x1D\xDF\xD6\xBB1"
    # @return [String]
    attribute :gid, :load => false

    # The URI for loading information about this resource
    # "spotify:track:6RGXtkDeWNP2gyASlfjzTr"
    # @return [String]
    attribute :uri, :load => false

    # The id used within the URI for this resource
    # "6RGXtkDeWNP2gyASlfjzTr"
    # @return [String]
    attribute :uri_id, :load => false

    # Initializes this resources with the given attributes.  This will continue
    # to call the superclass's constructor with any additional arguments that
    # get specified.
    # 
    # @api private
    def initialize(client, attributes = {}, *args)
      @loaded = false
      @metadata_loaded = false
      @client = client
      self.attributes = attributes
      super(*args)
    end

    # The unique identifier, represented in base16
    # 
    # @return [String] The Spotify ID for the resource
    def id
      @id ||= begin
        if @gid
          Radix::Base.new(Radix::BASE::HEX).encode(gid).rjust(32, '0')
        elsif @uri
          Radix::Base.new(Radix::BASE::HEX).convert(uri_id, BASE62_CHARS).rjust(32, '0')
        end
      end
    end

    # The unique group identifier, represented as bytes in base 16
    # 
    # @example "\xE1\x98|\x10\xDB\xC3OM\x8B\xE1\xB1\x1D\xDF\xD6\xBB1"
    # @return [String] The group id
    def gid
      @gid ||= id && Radix::Base.new(Radix::BASE::HEX).decode(id)
    end
    
    # The unique URI representing this resource in Spotify
    # 
    # @example "spotify:track:6RGXtkDeWNP2gyASlfjzTr"
    # @return [String] The URI for the resource
    def uri
      @uri ||= uri_id && "spotify:#{self.class.resource_name}:#{uri_id}"
    end

    # The id used within the resource's URI, represented in base62.
    # 
    # @example "6RGXtkDeWNP2gyASlfjzTr"
    # @return [String] The URI's id
    def uri_id
      @uri_id ||= begin
        if @uri
          @uri.split(':')[2]
        elsif @gid || @id
          Radix::Base.new(BASE62_CHARS).convert(id, Radix::BASE::HEX).rjust(22, '0')
        end
      end
    end

    # Loads the attributes for this resource from Spotify.  By default this is
    # a no-op and just marks the resource as loaded.
    # 
    # @return [true]
    def load
      load_metadata
      @loaded = true
    end
    alias :reload :load

    # Determines whether the current resource has been loaded from Spotify.
    # 
    # @return [Boolean] +true+ if the resource has been loaded, otherwise +false+
    def loaded?
      @loaded
    end

    # Looks up the metadata associated with this resource.
    # 
    # @api private
    # @return [Object, nil] +nil+ if there is no metadata schema associated, otherwise the result of the request
    def load_metadata
      if self.class.metadata_schema && !@metadata_loaded
        if @metadata_loader
          # Load the metadata externally
          @metadata_loader.call
          @metadata_loader = nil
        else
          # Load the metadata just for this single resource
          response = api('request',
            :uri => metadata_uri,
            :response_schema => self.class.metadata_schema
          )
          self.metadata = response['result']
        end
      end
    end

    # Updates this resource based on the given metadata
    # 
    # @api private
    # @param [Beefcake::Message, Proc] metadata The metadata to use or a proc for loading it
    def metadata=(metadata)
      if !metadata || metadata.is_a?(Proc)
        @metadata_loader = metadata
      else
        @metadata_loaded = true
        self.attributes = metadata.to_hash
      end
    end

    # The URI for looking up the resource's metadata
    # 
    # @api private
    # @return [String, nil] +nil+ if there is no metadata schema associated, otherwise the uri
    def metadata_uri
      if self.class.metadata_schema
        "hm://metadata/#{self.class.resource_name}/#{id}"
      end
    end

    # Attempts to set attributes on the object only if they've been explicitly
    # defined by the class.
    # 
    # @api private
    # @param [Hash] attributes The updated attributes for the resource
    def attributes=(attributes)
      if attributes
        attributes.each do |attribute, value|
          attribute = attribute.to_s
          __send__("#{attribute}=", value) if respond_to?("#{attribute}=", true)
        end
      end
    end

    # Forces this object to use PP's implementation of inspection.
    # 
    # @api private
    # @return [String]
    def pretty_print(q)
      q.pp_object(self)
    end
    alias inspect pretty_print_inspect

    # Defines the instance variables that should be printed when inspecting this
    # object.  This ignores the +@client+ and +@loaded+ variables.
    # 
    # @api private
    # @return [Array<Symbol>]
    def pretty_print_instance_variables
      (instance_variables - [:'@client', :'@loaded', :'@metadata_loaded', :'@metadata_loader']).sort
    end

    # Determines whether this resource is equal to another based on their
    # unique identifiers.
    # 
    # @param [Object] other The object this resource is being compared against
    # @return [Boolean] +true+ if the resource ids are equal, otherwise +false+
    def ==(other)
      if other && other.respond_to?(:id) && other.id
        other.id == id
      else
        false
      end
    end
    alias :eql? :==

    # Generates a hash for this resource based on the unique identifier
    # 
    # @return [Fixnum]
    def hash
      id.hash
    end

    private
    # The client that all APIs filter through
    attr_reader :client

    # Runs the given API command on the client.
    def api(command, options = {})
      client.api(command, options)
    end
  end
end

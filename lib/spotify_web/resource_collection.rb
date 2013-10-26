module SpotifyWeb
  # Represents a collection of related resources (of the same type) on
  # Spotify
  class ResourceCollection < Array
    # Initializes this collection with the given resources.  This will continue
    # to call the superclass's constructor with any additional arguments that
    # get specified.
    # 
    # @api private
    def initialize(client, *args)
      @client = client
      @loaded = false
      super(*args)

      # Load all resources if attempted for a single one
      each do |resource|
        resource.metadata = lambda { load unless loaded? }
      end
    end

    # Loads the attributes for these resources from Spotify.  By default this is
    # a no-op and just marks the resource as loaded.
    # 
    # @return [true]
    def load
      if count == 1
        # Remove the metadata loader / load directly from the resource
        first.metadata = nil
        first.load
      else
        # Load each resource's metadata
        metadata.each_with_index do |result, index|
          self[index].metadata = result
        end

        true
      end

      @loaded = true
    end
    alias :reload :load

    # Determines whether the current collection has been loaded from Spotify.
    # 
    # @return [Boolean] +true+ if the collection has been loaded, otherwise +false+
    def loaded?
      @loaded
    end

    # Looks up the metadata associated with all of the resources in this
    # collection.
    # 
    # @api private
    # @return [Array] The resulting metadata for each resource
    def metadata
      if any? && metadata_schema
        response = api('request',
          :uri => "hm://metadata/#{resource_name}s",
          :batch => true,
          :payload => map {|resource| {:uri => resource.metadata_uri}},
          :response_schema => metadata_schema
        )
        response['result']
      else
        []
      end
    end

    private
    # The types of resources being stored in this collection.  This should only
    # be called when there are actually resources available.
    def resource_class
      if any?
        first.class
      else
        raise ArgumentError, 'Cannot determine resource class on empty collection'
      end
    end

    # The Spotify name for the resource type
    def resource_name
      resource_class.resource_name
    end

    # The response schema used for looking up metadata associated with the
    # resources
    def metadata_schema
      resource_class.metadata_schema
    end

    # The client that all APIs filter through
    attr_reader :client

    # Runs the given API command on the client.
    def api(command, options = {})
      client.api(command, options)
    end
  end
end
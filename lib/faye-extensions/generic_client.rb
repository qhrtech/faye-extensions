# Takes care of spooling up a generic Faye client, which you can extend elsewhere
# (eg. from running a rake task in the main Rails app)

require 'eventmachine'

module FayeExtensions

  class GenericClient

    attr_accessor :client

    def initialize(client)
      @client = client
      run
    end

    def self.run
      EM.run {
        client = Faye::Client.new('http://localhost:9292/faye')
        client.add_extension(ClientAuth.new)
      }
    end

  end

end

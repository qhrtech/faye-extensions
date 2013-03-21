# This is a Faye client which takes care of multiple queues, including Assistant & Practitioner
# line-ups for Patients

require 'eventmachine'
require 'faye'
require 'json'
require 'json/add/core'

# Instead of POSTing for auth tokens over HTTPS, we can share the library this way
require_relative '../../faye_extensions.rb'

module FayeExtensions

  FayeExtensions.setup do |config|
    config.secret = ENV['FAYE_TOKEN'] || 'queenvictoria'
  end

  ASSISTANT_QUEUE_CHANNEL = '/assistants/queue_count'

  EM.run {

    client = Faye::Client.new('http://localhost:9292/faye')
    client.add_extension(ClientAuth.new)

    subscription = client.subscribe(ASSISTANT_QUEUE_CHANNEL) do |message|
      puts message
    end

    publication = client.publish(ASSISTANT_QUEUE_CHANNEL, {
      'text' => 'Hello world'
    })

    # publication.callback do
    #   puts "[PUBLISH SUCCEEDED]"
    # end

    # publication.errback do |error|
    #   puts "[PUBLISH FAILED] #{error.inspect}"
    #   # EM.stop_event_loop
    # end

  }

end

require 'net/http'

module FayeExtensions

  SERVER_ID = 'SSE'

  class Broadcast

    attr_reader :channel

    def initialize(channel)
      @channel = channel
    end

    def send(message)
      message = sign_message(message)
      request = Net::HTTP::Post.new(uri.path)
      request.set_form_data(:message => message.to_json)
      http.request(request)
    end

    private

      def sign_message(message)
        { :channel => channel,
          :data    => message,
          :ext     => message_ext }
      end

      def message_ext
        { TOKEN_KEY => AuthToken.assign_token(SERVER_ID, channel).as_json }
      end

      def http
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          # TODO could not verify the cer for some reason
          # http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          # http.ca_path = Rails.root.join('lib', 'certs', 'ca-bundle.crt').to_s
          # http.verify_depth = 5
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        http
      end

      def uri
        @uri ||= URI.parse(FayeExtensions.broadcast_url)
      end

  end

end

# This class is an extension (interceptor) added to all Ruby Faye clients, ensuring
# that auth is taken care of when sending and receiving messages

module FayeExtensions

  class ClientAuth

    TOKEN_KEY = 'auth_token'
    ERROR_MESSAGE = '403::Authentication required'

    def incoming(message, callback)
      # Maybe see if it's a self-published message

      callback.call(message)
    end

    def outgoing(message, callback)
      message = sign_message(message)

      callback.call(message)
    end

    def added(client)
      puts "FayeExtensions::ClientAuth, checkin' in."
    end

    private

      def sign_message(message)
        channel = message['subscription'] || message['channel']
        message["ext"] = { TOKEN_KEY => AuthToken.assign_token('FAYE_QUEUE', channel).as_json }
        message
      end

  end

end

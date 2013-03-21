# This class is an extension added to the Faye server to check
# that subscription requests have been authorized by the rails app

module FayeExtensions

  TOKEN_KEY = 'auth_token'
  ERROR_MESSAGE = '403::Authentication required'

  class ChannelAuth

    def incoming(message, callback)

      if message['channel'] == '/meta/subscribe'
        message['error'] = ERROR_MESSAGE unless valid_request?(message['subscription'], message)
      elsif !message['channel'].match(/^\/meta\//)
        message['error'] = ERROR_MESSAGE unless valid_request?(message['channel'], message)
      end

      callback.call(message)
    end

    def outgoing(message, callback)
      message['ext'].delete(TOKEN_KEY) if message['ext']
      callback.call(message)
    end

    private

      def valid_request?(channel, message)
        token = get_token(message)
        token && token.authorized?(channel)
      end

      def get_token(message)
        if token_json = (message['ext'] && message['ext'][TOKEN_KEY])
          AuthToken.from_json(token_json)
        end
      end

  end

end
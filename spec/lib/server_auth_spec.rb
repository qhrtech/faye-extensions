require 'rspec'
require 'faye-extensions/server_auth'

module FayeExtensions ; class AuthToken ; end ; end

class CbStub
  attr_reader :message
  def call(message)
    @message = message
  end
end

describe FayeExtensions::ServerAuth do

  let(:callback) { CbStub.new }
  let(:auth)     { FayeExtensions::ServerAuth.new }
  let(:message) do
    {
      "channel"      => "/meta/subscribe",
      "clientId"     => "Un1q31d3nt1f13r",
      "subscription" => "/foo/**",
      "ext"          => {
        "auth_token" => {
          "user_id"   => 3,
          "token"     => "A323B",
          "timestamp" => Time.now.utc.to_s
        }
      }
    }
  end

  describe '#incoming' do

    it 'passes on messages that are not for non-subscription meta/channels' do
      message = {'channel' => '/meta/other'}
      auth.incoming(message, callback)
      callback.message['error'].should be_nil
    end

    it 'adds errors to subscriptions that do not include a auth token extension' do
      message['ext'] = {}
      auth.incoming(message, callback)
      callback.message['error'].should_not be_nil
    end

    it 'adds errors to subscriptions that have invalid tokens' do
      token = double('token', :authorized? => false)
      FayeExtensions::AuthToken.stub(:from_json => token)
      auth.incoming(message, callback)
      callback.message['error'].should_not be_nil
    end

    it 'passes messages through that include valid tokens' do
      token = double('token', :authorized? => true)
      FayeExtensions::AuthToken.stub(:from_json => token)
      auth.incoming(message, callback)
      callback.message['error'].should be_nil
      callback.message == message
    end

    it 'checks auth for publish messages' do
      message = {
        "channel"      => "/cases/4",
        "clientId"     => "Un1q31d3nt1f13r",
        "message"      => {},
        "ext"          => {
          "auth_token" => {
            "user_id"   => 3,
            "token"     => "A323B",
            "timestamp" => Time.now.utc.to_s
          }
        }
      }
      token = double('token')
      FayeExtensions::AuthToken.stub(:from_json => token)
      token.should_receive(:authorized?).with('/cases/4').and_return(true)
      auth.incoming(message, callback)
      callback.message['error'].should be_nil
      callback.message == message
    end

  end

  describe '#outgoing' do

    it 'deletes auth_tokens from outgoing messages' do
      auth.outgoing(message, callback)
      callback.message['ext']['auth_token'].should be_nil
    end

  end

end

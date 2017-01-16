require "faye-extensions/version"
require "faye-extensions/constants"
require "faye-extensions/auth_token"
require "faye-extensions/server_auth"
require "faye-extensions/client_auth"
require "faye-extensions/config"
require "faye-extensions/broadcast"
require "faye-extensions/logger"

module FayeExtensions

  extend self

  def config
    @config ||= Config.new('sha256', 3600, nil, 'http://localhost:9292/faye', :debug, [])
  end

  def setup
    yield(config)
  end

  def secret
    config.secret
  end

  def token_life
    config.token_life
  end

  def hash_algorithm
    config.hash_algorithm
  end

  def broadcast_url
    config.broadcast_url
  end
  
  def logger
    @logger ||= FayeExtensions::Logger.new config
  end

end

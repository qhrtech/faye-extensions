require 'openssl'
require 'time'

module FayeExtensions

  class AuthToken

    private_class_method :new

    def self.assign_token(user_id, channel)
      new(:user_id => user_id, :channel => channel)
    end

    def self.from_json(json)
      attrs = json.inject({}) { |h, (k,v)| h[k.to_sym] = v ; h }
      new(attrs)
    end

    attr_accessor :channel, :timestamp
    attr_reader :user_id, :token

    def initialize(args)
      @user_id   = args.fetch(:user_id)
      @channel   = args.fetch(:channel, nil)
      @token     = args.fetch(:token, nil)
      @timestamp = args.fetch(:timestamp, nil)
    end

    def as_json(options={})
      self.timestamp = expires_at_stamp
      { :user_id   => user_id,
        :token     => create_digest,
        :timestamp => timestamp }
    end

    def authorized?(requested_channel)
      self.channel = requested_channel
      token && token == create_digest && time_valid?
    end

    private

      def create_digest
        digest = OpenSSL::HMAC.new(FayeExtensions.secret, digest_algorithm)
        digest << "#{user_id}:#{channel}:#{timestamp}"
        digest.hexdigest
      end

      def digest_algorithm
        OpenSSL::Digest.new(FayeExtensions.hash_algorithm)
      end

      def expires_at_stamp
        (Time.now.utc + FayeExtensions.token_life).iso8601
      end

      def time_valid?
        self.timestamp && Time.iso8601(self.timestamp) > Time.now.utc
      end

  end

end
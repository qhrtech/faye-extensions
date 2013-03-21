require 'rspec'
require 'faye-extensions/auth_token'

describe FayeExtensions::AuthToken do

  before do
    FayeExtensions.stub(:secret => 'sekret')
    FayeExtensions.stub(:token_life => 3600)
    FayeExtensions.stub(:hash_algorithm => 'sha256')
  end

  describe '.assign_token' do
    it 'returns a AuthToken' do
      token = FayeExtensions::AuthToken.assign_token('foo', 'bar')
      token.should be_a(FayeExtensions::AuthToken)
    end
  end

  describe '.from_json' do
    it 'returns a AuthToken' do
      json = { :user_id => 'foo', :channel => 'bar', :timestamp => Time.now.utc.to_s }
      token = FayeExtensions::AuthToken.from_json(json)
      token.should be_a(FayeExtensions::AuthToken)
    end

    it 'handles a hash with symbol keys' do
      json = { :user_id => 'foo', :channel => 'bar', :timestamp => Time.now.utc.to_s }
      token = FayeExtensions::AuthToken.from_json(json)
      token.user_id.should == 'foo'
    end

    it 'handles a hash with string keys' do
      json = { 'user_id' => 'foo', 'channel' => 'bar', 'timestamp' => Time.now.utc.to_s }
      token = FayeExtensions::AuthToken.from_json(json)
      token.user_id.should == 'foo'
    end

  end

  describe '#as_json' do

    let(:token) { FayeExtensions::AuthToken.assign_token('foo', 'bar/channel') }

    it 'retuns the user_id' do
      token.as_json[:user_id].should == 'foo'
    end

    it 'retuns a HMAC token' do
      digest = stub('digest')
      digest.should_receive(:<<)
      digest.should_receive(:hexdigest).and_return('banana')
      OpenSSL::HMAC.stub(:new => digest)
      token.as_json[:token].should == 'banana'
    end

    it 'returns a timestamp' do
      Time.stub_chain(:now, :utc).and_return('foo')
      token.as_json[:timestamp].should == 'foo'
    end

  end

  describe '#authorized?' do

    it 'retuns false for newly assigned tokens' do
      token = FayeExtensions::AuthToken.assign_token('foo', 'bar/channel')
      token.authorized?('bar/channel').should be_false
    end

    it 'retuns true for tokens that have been transferred through json' do
      json = FayeExtensions::AuthToken.assign_token('foo', 'bar/channel').as_json
      token = FayeExtensions::AuthToken.from_json(json)
      token.authorized?('bar/channel').should be_true
    end

    it 'retuns false if the requested channel does not match the assigned channel' do
      json = FayeExtensions::AuthToken.assign_token('foo', 'bar/channel').as_json
      FayeExtensions::AuthToken.from_json(json).authorized?('other/channel').should be_false
    end

    it 'retuns false if the json token was tamperred with' do
      json = FayeExtensions::AuthToken.assign_token('foo', 'bar/channel').as_json
      json[:token] = 'tamperred token'
      FayeExtensions::AuthToken.from_json(json).authorized?('bar/channel').should be_false
    end

    it 'retuns false for old tokens' do
      old_time = Time.now - 100000
      now_time = Time.now
      Time.stub(:now => old_time)
      json = FayeExtensions::AuthToken.assign_token('foo', 'bar/channel').as_json
      Time.stub(:now => now_time)
      FayeExtensions::AuthToken.from_json(json).authorized?('bar/channel').should be_false
    end

  end

end
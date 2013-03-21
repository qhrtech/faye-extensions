require 'rspec'
require 'faye-extensions'

describe FayeExtensions do

  describe 'setup' do
    it 'lets you set the expire interval and secret' do
      FayeExtensions.setup do |c|
        c.secret = 'sekret'
        c.token_life = 3600
      end
      FayeExtensions.secret.should == 'sekret'
      FayeExtensions.token_life.should == 3600
    end
  end

end
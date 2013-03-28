require 'rspec'
require 'faye'
require 'faye-extensions'

describe FayeExtensions do

  describe 'setup' do

    after(:each) do
      FayeExtensions.instance_variable_defined?(:@logger) && FayeExtensions.remove_instance_variable(:@logger)
      FayeExtensions.instance_variable_defined?(:@config) && FayeExtensions.remove_instance_variable(:@config)
    end

    it 'lets you set the expire interval and secret' do
      FayeExtensions.setup do |c|
        c.secret = 'sekret'
        c.token_life = 3600
      end
      FayeExtensions.secret.should == 'sekret'
      FayeExtensions.token_life.should == 3600
    end

    it "does not create log targets by default" do
      FayeExtensions.logger.instance_variable_get("@targets").length.should == 0
      Faye::Logging.log_level.should == :debug
    end

    it "lets you configure log targets and levels" do
      FayeExtensions.setup do |c|
        c.log_level = :error
        c.log_targets = [:stdout, :syslog]
      end

      targets = FayeExtensions.logger.instance_variable_get("@targets")
      targets.length.should == 2
      Faye::Logging.log_level.should == :error
    end

  end

end
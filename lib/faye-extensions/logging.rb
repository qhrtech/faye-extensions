require 'syslog/logger'
require 'airbrake'

module FayeExtensions

  class Logging

    TARGETS = [:airbrake, :syslog, :stdout]
    LEVELS = [:debug, :info, :warn, :error]

    def initialize

      # Configure Targets
      @targets = Hash.new

      # Simple puts to STDOUT
      @targets[:stdout] = lambda { |l, m| puts m }

      # Abusing Airbrake notifications
      Airbrake.configure { |config| config.api_key = ENV['AIRBRAKE_API_KEY'] }
      @targets[:airbrake] = lambda { |l, m| Airbrake.notify Exception.new m }

      # SyslogLogger
      logger = Syslog::Logger.new "medeo-faye-clients"
      @targets[:syslog] = lambda { |l, m| logger.send l, m }

    end

    def self.bootstrap opts={}
      new.bootstrap opts
    end

    def bootstrap opts={}

      # Defaults
      level = opts[:level] || LEVELS.last
      targets = opts[:targets] && (opts[:targets] &= TARGETS) || [TARGETS.last]

      # Set faye log level
      Faye::Logging.log_level = level

      # Lambda inception
      lambda do |m|
        targets.each do |t|
          @targets[t].call level, m
        end
      end

    end

  end
end
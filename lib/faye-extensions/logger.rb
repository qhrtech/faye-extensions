require "faye"
require "logger"
require "syslog/logger"

module FayeExtensions

  class Logger

    TARGETS = [:syslog, :stdout]
    LEVELS = [:debug, :info, :warn, :error]

    def initialize(config)
      Faye::Logging.log_level = config.log_level
      targets = config.log_targets & TARGETS

      @targets = Array.new
      return if targets.empty?

      @targets << ::Logger.new(STDOUT) if targets.include? :stdout
      @targets << Syslog::Logger.new("faye-extensions") if targets.include? :syslog

      Faye.logger = lambda do |msg|
        # Parse faye log message
        match = msg.match /\[(\w*)\]\s(.+)/

        # Extract log level and message
        level = match[1].downcase.to_sym
        message = match[2]

        # Log with parsed level and message content
        log level, message
      end
    end

    def log(level, msg)
      @targets.each do |logger|
        logger.send level, msg
      end
    end

  end
end
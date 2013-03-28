require "faye"
require "logger"
require "syslog/logger"

module FayeExtensions

  class Logger

    TARGETS = [:syslog, :stdout]
    LEVELS = [:debug, :info, :warn, :error]

    def initialize(config)

      level = config.log_level
      targets = config.log_targets & TARGETS

      @targets = Array.new
      return if targets.empty?

      @targets << Logger.new STDOUT if targets.include? :stdout
      @targets << Syslog::Logger.new "faye-extensions" if targets.include? :syslog

      Faye::Logging.log_level = level
      Faye.logger = lambda { |msg| log level, msg }
    end

    def log(level, msg)
      @targets.each do |logger|
        logger.send level, msg
      end
    end

  end
end
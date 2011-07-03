module Gearup
  module Logger
    @logger = nil

    def set_logger(logger)
      @logger = logger
    end

    def log(message, level = :debug)
      fail "Need to call set_logger" unless @logger
      @logger.add(sym_to_level(level)) {
        message
      }
    end

    module_function :set_logger, :log

    private

    def sym_to_level(sym)
      {
        :debug => ::Logger::DEBUG,
        :info => ::Logger::INFO,
        :warn => ::Logger::WARN,
        :error => ::Logger::ERROR,
        :fatal => ::Logger::FATAL,
        :unknown => ::Logger::UNKNOWN
      }[sym]
    end
    
    module_function :sym_to_level
  end
end

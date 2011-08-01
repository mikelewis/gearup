module Gearup
  module Logger
    def logger
      @@Logger ||= ::Logger.new(CONFIG.log_file)
    end

    def log(message, level = :debug)
      logger.add(sym_to_level(level)) {
        message
      }
    end

    module_function :log, :logger

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

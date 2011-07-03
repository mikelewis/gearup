module Gearup
  class BaseJob
    include EM::Deferrable
    def do_job(*args)
      # Log?
      begin
        run(*args)
      rescue ArgumentError
        fail("BOO")
        Logger.log("Wrong number of arguments for #{self.class.name} run method")
      end
    end

    def run
      raise "Should be implemented by subclasses"
    end
  end
end

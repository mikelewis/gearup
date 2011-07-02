module Gearup
  class BaseJob
    include EM::Deferrable
    def do_job(*args)
      # Log?
      run(*args)
    end

    def run
      raise "Should be implemented by subclasses"
    end
  end
end

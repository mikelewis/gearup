module Gearup
  class BaseJob
    include EM::Deferrable

    attr_accessor :job

    def do_job(*args)
      # Log?
      begin
        run(*args)
      rescue ArgumentError
        fail("BOO")
        Logger.log("Wrong number of arguments for #{self.class.name} run method")
      end
    end

    def update_ticket_status(status, &blk)
      if block_given? #async
        Ticket.aupdate_ticket(@job["ticket"], status, &blk) if @job["ticket"]
      else
        Ticket.update_ticket(@job["ticket"], status) if @job["ticket"]
      end
    end

    def run
      raise "Should be implemented by subclasses"
    end
  end
end

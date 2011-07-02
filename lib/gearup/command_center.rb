module Gearup
  class CommandCenter < EM::Connection
    def initialize(worker_pids, master_pid)
      @worker_pids, @master_pid = worker_pids, master_pid
      puts "Got #{@worker_pids} and #{@master_pid}"
    end
  end
end

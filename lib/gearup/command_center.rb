module Gearup
  class CommandCenter < EM::Connection
    def initialize(worker_pids, master_pid)
      @worker_pids, @master_pid = worker_pids, master_pid
    end

    class << self
      def start(num_workers, job_dir)

        worker_pids = []
        master_pid = nil
        master_sock = "#{CONFIG.master_sock}#{Process.pid}"

        #trap("SIGINT"){Process.kill("SIGKILL", *pids); exit!}
        master_pid = Kernel.fork do
          EM.run do
            EM.start_server master_sock, Master
            sleep 0.5 #wait for workers to join
          end
        end

        #let master setup
        sleep 0.5
        num_workers.to_i.times do
          worker_pids << EM.fork_reactor do
            EM.connect master_sock, Worker, job_dir
          end
        end

        EM.run do
          EM.start_server CONFIG.command_center.server, CONFIG.command_center.port, self, worker_pids, master_pid
        end
      end
    end
  end
end

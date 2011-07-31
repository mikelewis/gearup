module Gearup
  class CommandCenter < EM::Connection
    def initialize(worker_pids, master_pid)
      @worker_pids, @master_pid = worker_pids, master_pid
    end

    class << self
      @@master_pid = nil
      @@worker_pids = []
      def master_pid
        @@master_pid
      end

      def worker_pids
        @@worker_pids
      end

      def shutdown
        @@worker_pids.each do |pid|
          Process.kill("SIGKILL", pid)
        end

        Process.kill("SIGKILL", @@master_pid)
      end

      def start
        num_workers = CONFIG.num_workers
        job_dir = CONFIG.job_dir

        master_sock = "#{CONFIG.master_sock}#{Process.pid}"

        #trap("SIGINT"){Process.kill("SIGKILL", *pids); exit!}
        @@master_pid = Kernel.fork do
          EM.run do
            EM.start_server master_sock, Master
            sleep 0.5 #wait for workers to join
          end
        end

        #let master setup
        sleep 0.5
        num_workers.to_i.times do
          @@worker_pids << EM.fork_reactor do
            EM.connect master_sock, Worker, job_dir
          end
        end

        EM.run do
    #      EM.start_server CONFIG.command_center.server, CONFIG.command_center.port, self, worker_pids, master_pid
        end
      end
    end
  end
end

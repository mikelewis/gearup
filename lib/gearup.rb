module Gearup
  require 'eventmachine'
  require 'set'
  require 'json'
  require 'logger'
  require 'stomp'
  require 'simpleconf'
  require 'trollop'

  # Your code goes here...
  require 'gearup/logger'


  CONFIG = SimpleConf {
    queue {
      server "localhost"
      port 61613
      name "/queue/test"
      prefetch_size 100
    }

    master_sock "/tmp/gearup.sock"

    command_center {
      server "0.0.0.0"
      port 10053
    }

    log_file "log/gearup.log"
    job_dir "test_jobs"
    num_workers 1
  }

  Logger.set_logger(::Logger.new(CONFIG.log_file, 'daily'))

  autoload :Client, 'gearup/client'
  autoload :CommandCenter, 'gearup/command_center'
  autoload :Master, 'gearup/master'
  autoload :Worker, 'gearup/worker'
  autoload :StompClient, 'gearup/stomp_client'
  autoload :BaseJob, 'gearup/base_job'
end

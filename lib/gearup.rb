module Gearup
  require 'eventmachine'
  require 'em-redis'
  require 'redis'
  require 'set'
  require 'json'
  require 'stomp'
  require 'simpleconf'
  require 'trollop'
  gem "logger"
  require "logger"
  require 'daemons'

  require 'gearup/logger'

  GEARUP_DIR = File.expand_path(File.dirname(__FILE__) + "/..")
  
  PID_DIR = File.join(GEARUP_DIR, 'tmp', 'pids')

  TICKET_STATUS = {
    :queued => "QUEUED",
    :processing => "PROCESSING",
    :failed => "FAILED",
    :success => "SUCCESS"
  }

  CONFIG = SimpleConf {
    queue {
      server "localhost"
      port 61613
      name "/queue/test"
      prefetch_size 100
      username "guest"
      password "guest"
    }

    redis {
      host "localhost"
      port 6379
      database 0
      namespace "gearup"
    }

    master_sock "/tmp/gearup.sock"

    command_center {
      server "0.0.0.0"
      port 10053
    }

    log_file "#{GEARUP_DIR}/log/gearup.log"
    job_dir "test_jobs"
    num_workers 1

    ticket_ttl 3600
  }


  autoload :Client, 'gearup/client'
  autoload :CommandCenter, 'gearup/command_center'
  autoload :Master, 'gearup/master'
  autoload :Worker, 'gearup/worker'
  autoload :StompClient, 'gearup/stomp_client'
  autoload :BaseJob, 'gearup/base_job'
  autoload :Ticket, 'gearup/ticket'
end

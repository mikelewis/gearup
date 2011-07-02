module Gearup
  require 'eventmachine'
  require 'set'
  require 'json'

  # Your code goes here...
  autoload :CommandCenter, 'gearup/command_center'
  autoload :Master, 'gearup/master'
  autoload :Worker, 'gearup/worker'
  autoload :StompClient, 'gearup/stomp_client'
  autoload :BaseJob, 'gearup/base_job'
end

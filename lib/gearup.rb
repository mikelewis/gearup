module Gearup
  require 'eventmachine'
  require 'set'
  require 'json'
  require 'logger'
  require 'stomp'

  # Your code goes here...
  require 'gearup/logger'

  Logger.set_logger(::Logger.new('gearup.log', 'daily'))

  autoload :Client, 'gearup/client'
  autoload :CommandCenter, 'gearup/command_center'
  autoload :Master, 'gearup/master'
  autoload :Worker, 'gearup/worker'
  autoload :StompClient, 'gearup/stomp_client'
  autoload :BaseJob, 'gearup/base_job'
end

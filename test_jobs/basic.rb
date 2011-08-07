$:.unshift File.dirname(__FILE__) + '/../lib'
require 'gearup'

class BasicJob < Gearup::BaseJob
  def run(name)
    EM.defer do
      sleep 5
      update_ticket_status("AWAKE") do
        sleep 3
        succeed("HI#{name}")
      end
    end
  end
end


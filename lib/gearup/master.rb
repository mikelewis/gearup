module Gearup
  class Master < EM::Connection
    include EM::P::ObjectProtocol
    @@stomp = nil
    @@workers = {}
    @@jobs = EM::Queue.new

    def post_init
      Logger.log("Got Worker")
      @@workers[self] = 0
      @@stomp = EM.connect 'localhost', 61613, Gearup::StompClient unless @@stomp
    end

    def serializer
      JSON
    end

    def receive_object(obj)
      case obj['type']
      when 'finished_job'
        self.class.finish_job(self, obj['message_id'])
      else
      end
    end

    def self.receive_msg(msg)
      job = {:message_id => msg.header["message-id"]}.merge(JSON.parse(msg.body))
      @@jobs.push(job)
      @@jobs.pop do |job|
        worker = get_worker
        @@workers[worker] += 1
        worker.send_object(job)
      end
    end

    def self.finish_job(worker, msg_id)
      @@workers[worker] -= 1
      @@stomp.ack_msg(msg_id)
    end

    def self.get_worker
      @@workers.min_by{|worker, jobs| jobs}[0]
    end

    def self.workers
      @@workers
    end

  end
end

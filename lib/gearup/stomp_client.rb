module Gearup
  module StompClient
    include EM::Protocols::Stomp

    def subscribe(dest, opts={})
      opts[:ack] ||= "auto"
      send_frame "SUBSCRIBE", {:destination=>dest}.merge(opts)
    end

    def connection_completed
      connect :login => 'guest', :passcode => 'guest'
    end

    def receive_msg(msg)
      if msg.command == "CONNECTED"
        Logger.log("Stomp client connected")
        subscribe CONFIG.queue.name, :ack => 'client-individual', "activemq.prefetchSize" => CONFIG.queue.prefetch_size
      elsif msg.command == "MESSAGE"
        Master.receive_msg(msg)
      end
    end

    def ack_msg(msg_id)
      ack msg_id
    end
  end
end

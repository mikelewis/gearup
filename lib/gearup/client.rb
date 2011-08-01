module Gearup
  module Client
    @stomp_client = ::Stomp::Client.new(CONFIG.queue.username, CONFIG.queue.password, CONFIG.queue.server, CONFIG.queue.port)
    @queue_name = CONFIG.queue.name
    class << self
      def method_missing(meth, *args, &blk)
        define_method(meth) do |*args, &blk|
          ticket_num = Ticket.create_ticket
          job = {:type=>meth, :args=>args, :ticket => ticket_num}
          @stomp_client.publish(@queue_name, JSON.dump(job))
          ticket_num
        end
        module_function meth
        send(meth, *args)
      end
    end
  end
end

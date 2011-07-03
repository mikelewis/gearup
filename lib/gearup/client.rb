module Gearup
  module Client
    @stomp_client = ::Stomp::Client.new("guest", "guest", "localhost", 61613)
    @queue_name = "/queue/test"
    class << self
      def method_missing(meth, *args, &blk)
        define_method(meth) do |*args, &blk|
          job = {:type=>meth, :args=>args}
          @stomp_client.publish(@queue_name, JSON.dump(job))
        end
        module_function meth
        send(meth, *args)
      end
    end
  end
end

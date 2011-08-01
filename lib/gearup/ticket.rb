module Gearup
  module Ticket
    class << self
      def redis
        @redis_client ||= ::Redis.connect :host => CONFIG.redis.host, :port => CONFIG.redis.port
      end

      def incr_ticket_count
        redis.incr("#{CONFIG.redis.namespace}}:ticket_count")
      end

      def ticket_key(ticket_num)
        "#{CONFIG.redis.namespace}:ticket:#{ticket_num}"
      end

      def get_status(ticket_num)
        redis.get(ticket_key(ticket_num))
      end

      def update_ticket(ticket_num, status)
        redis.set(ticket_key(ticket_num), status)
      end

      def create_ticket
        ticket_num = incr_ticket_count
        redis.setex(ticket_key(ticket_num), CONFIG.ticket_ttl, TICKET_STATUS[:queued])
        ticket_num
      end

    end
  end
end

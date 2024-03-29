module Gearup
  class Worker < EM::Connection
    include EM::P::ObjectProtocol
    #    @@queue = EM::Queue.new

    def initialize(job_dir)
      Logger.log("Init Worker")
      @job_dir = job_dir
      @queue = EM::Queue.new
    end

    def serializer
      JSON
    end

    def finish_job(job, status = :success)
      p = Proc.new do
        send_object(:type=>'finished_job', :message_id=>job['message_id'])
      end
      if job["ticket"]
        if status == :success
          Ticket.aupdate_ticket(job["ticket"], TICKET_STATUS[:success], &p)
        else
          Ticket.aupdate_ticket(job["ticket"], TICKET_STATUS[:failed], &p)
        end
      else
        p.call
      end
    end

    def receive_object(job)
      @queue.push(job)

      @queue.pop do |job|
        EM.defer do
          klass = load_job_class(job["type"])
          finish_job(job, :fail) unless klass

          if klass
            klass_obj = klass.new
            klass_obj.job = job
            klass_obj.callback {|result|
              puts "SUCCESS GOT #{result}"
              finish_job(job)
            }

            klass_obj.errback {|result|
              puts "ERROR FOR #{result}"
              finish_job(job, :fail)
            }

            do_work_proc = Proc.new do
              klass_obj.do_job(*job['args'])
              Logger.log("Working on #{job["ticket"]}") if job["ticket"]
            end

            if job["ticket"]
              Ticket.aupdate_ticket(job["ticket"], TICKET_STATUS[:processing], &do_work_proc)
            else
              do_work_proc.call
            end
          end
        end
      end
    end

    def load_job_class(name)
      class_name = job_class_name_from_string(name)

      klass = nil
      klass = begin
                Kernel.const_get(class_name)
              rescue NameError
                begin
                  load_class_from_file(name, class_name) 
                rescue => e
                  Logger.log(e.message, :error)
                  nil
                end
              end
    end

    def load_class_from_file(name, class_name=nil)
      class_name ||= job_class_name_from_string(name)
      name.downcase!
      begin
        location = "#{@job_dir}/#{name}"
        require location
      rescue LoadError => e
        fail "Can't find a job named #{name} at #{location}"
      end

      begin
        Kernel.const_get(class_name)
      rescue NameError
        fail "Could load #{location} but couldn't find #{name}"
      end

    end

    def job_class_name_from_string(str)
      "#{str.downcase.capitalize.gsub(/_\w/){|s| s[1].upcase}}Job"
    end

  end
end

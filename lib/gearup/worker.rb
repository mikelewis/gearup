module Gearup
  class Worker < EM::Connection
    include EM::P::ObjectProtocol
    #    @@queue = EM::Queue.new

    def initialize(job_dir)
      @job_dir = job_dir
      @queue = EM::Queue.new
    end

    def serializer
      JSON
    end

    def finish_job(job, status = :success)
      if status == :success
        puts "SUCCESS"
      else
        puts "FAILURE"
      end

      send_object(:type=>'finished_job', :message_id=>job['message_id'])
    end

    def receive_object(job)
      @queue.push(job)

      @queue.pop do |job|
        EM.defer do
          klass = load_job_class(job["type"])
          finish_job(job, :fail) unless klass

          if klass
            klass_obj = klass.new
            klass_obj.callback {|result|
              puts "SUCCESS GOT #{result}"
              finish_job(job)
            }

            klass_obj.errback {|result|
              puts "ERROR FOR #{result}"
              finish_job(job, :fail)
            }
            klass_obj.do_job(*job['args'])
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
                load_class_from_file(name, class_name) rescue nil
              end
    end

    def load_class_from_file(name, class_name=nil)
      class_name ||= job_class_name_from_string(name)
      name.downcase!
      begin
        location = "#{@job_dir}/#{name}"
        require location
      rescue LoadError => e
        puts "Can't find a job named #{name} at #{location}"
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

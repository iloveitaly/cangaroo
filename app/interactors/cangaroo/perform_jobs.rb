module Cangaroo
  class PerformJobs
    include Cangaroo::Log
    include Interactor

    def call
      data.each do |type, payloads|
        payloads.each { |payload| enqueue_jobs(type, payload) }
      end
    end

    private

    def data
      @data ||= JSON.parse(context.json_body)
    end

    def enqueue_jobs(type, payload)
      initialize_jobs(type, payload).each do |job|
        # TODO roll this into a magic 'job' key
        log_attributes = {
          job_class: job.class.to_s,
          payload_state: job.payload_state,
          object_type: job.translation.object_type,
          object_key: job.translation.object_key,
          object_id: job.translation.object_id
        }

        if job.perform?
          log.info 'job queued', log_attributes

          job.enqueue
        else
          # TODO persist translation record for audit trail?

          log.info 'job skipped', log_attributes
        end
      end
    end

    def initialize_jobs(type, payload)
      context.jobs.map do |klass|
        klass.new(
          connection: context.source_connection,
          type: type,
          payload: payload
        )
      end
    end
  end
end

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
        if job.perform?
          # TODO log simplified info about payload info is being queued
          job.enqueue
        else
          # TODO persist translation for audit trail?

          log.info 'skipping payload, no jobs',
            payload: payload,
            payload_type: type
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

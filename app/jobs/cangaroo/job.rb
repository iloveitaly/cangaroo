module Cangaroo
  class Job < ActiveJob::Base
    include Cangaroo::Log
    include Cangaroo::ClassConfiguration

    queue_as :cangaroo

    class_configuration :connection
    class_configuration :path, ''
    class_configuration :parameters, {}
    class_configuration :process_response, true

    def perform(*)
      log.set_context(job: self)

      restart_flow(connection_request)
    end

    def perform?
      fail NotImplementedError
    end

    def transform
      { type.singularize => payload }
    end

    protected if !Rails.env.test?

    def connection_request
      translation.save!

      log.info 'attempting translation',
        destination_connection: destination_connection.name,
        path: path,
        translation: translation

      response = Cangaroo::Webhook::Client.new(destination_connection, path)
        .post(transform, @job_id, parameters, translation)

      translation.update_column :response, (response.blank?) ? {} : response

      response
    end

    def restart_flow(response)
      # if no json was returned, the response should be discarded
      return if response.blank?

      unless self.process_response
        return
      end

      if response.blank?
        log.info 'blank response; not processing'
        return
      end

      PerformFlow.call(
        source_connection: destination_connection,
        json_body: response.to_json,
        jobs: Rails.configuration.cangaroo.jobs
      )
    end

    def source_connection
      arguments.first.fetch(:connection)
    end

    def type
      arguments.first.fetch(:type)
    end

    def payload
      arguments.first.fetch(:payload)
    end

    def destination_connection
      @connection ||= Cangaroo::Connection.find_by!(name: connection)
    end

    def translation
      # NOTE @job_id will remain consistent across retries
      # TODO we should move this logic to the translation model

      @translation ||= Cangaroo::Translation.where(job_id: @job_id).first_or_initialize(
        # TODO use job in place of destination connection
        # TODO use source job is place of source connection
        #      ^ this will provide more detail to the user

        source_connection: source_connection,
        destination_connection: destination_connection,

        object_type: self.type,

        request: self.payload
      )
    end
  end
end

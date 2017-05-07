module Cangaroo
  class PollJob < ActiveJob::Base
    include Cangaroo::Log
    include Cangaroo::ClassConfiguration

    queue_as :cangaroo

    class_configuration :connection
    class_configuration :frequency, 1.day
    class_configuration :frequency_adjustment, 0
    class_configuration :path, ''
    class_configuration :parameters, {}

    def perform(*)
      log.set_context(job: self)

      current_time = DateTime.now

      if !perform?(current_time)
        log.info 'skipping poll'
        return
      end

      adjusted_last_poll_timestamp = last_poll_timestamp.to_i - self.class.frequency_adjustment

      log.info 'initiating poll', last_poll: adjusted_last_poll_timestamp

      response = Cangaroo::Webhook::Client.new(destination_connection, path)
        .post({ last_poll: adjusted_last_poll_timestamp }, @job_id, parameters)

      log.info 'processing poll results'

      command = HandleRequest.call(
        key: destination_connection.key,
        token: destination_connection.token,
        json_body: response.to_json,
        jobs: Rails.configuration.cangaroo.jobs
      )

      if !command.success?
        fail Cangaroo::Webhook::Error, command.message
      end

      log.info 'updating last poll', last_poll: current_time, last_poll_stamp: current_time.to_i

      last_job_poll = Cangaroo::PollTimestamp.for_class(self.class)
      last_job_poll.value = current_time
      last_job_poll.save!

      log.reset_context!
    end

    def perform?(execution_time)
      last_poll_timestamp.nil? ||
        execution_time.to_i - last_poll_timestamp.to_i > self.class.frequency
    end

    protected

      def last_poll_timestamp
        @last_poll_timestamp ||= Cangaroo::PollTimestamp.for_class(self.class).value || Time.at(0).to_datetime
      end

      def destination_connection
        @connection ||= Cangaroo::Connection.find_by!(name: connection)
      end

  end
end

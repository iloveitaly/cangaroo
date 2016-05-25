module Cangaroo
  class Translation < ActiveRecord::Base
    include Cangaroo::Log

    belongs_to :destination_connection, class_name: 'Cangaroo::Connection'
    belongs_to :source_connection, class_name: 'Cangaroo::Connection'

    has_many :attempts

    def request=(payload)
      super

      self.object_id = nil
      self.object_key = nil

      determine_payload_identifier

      self.request
    end

    def successful?
      !!self.response
    end

    def related_translations
      Cangaroo::Translation.where(
        object_type: self.object_type,
        object_key: self.object_key,
        object_id: self.object_id,
      )
      .where.not(job_id: self.job_id)
    end

    def determine_object_key_from_payload
      Rails.configuration.cangaroo.payload_keys.each do |payload_key|
        if self.request[payload_key].present?
          return payload_key
        end
      end

      nil
    end

    def determine_payload_identifier
      self.object_key = determine_object_key_from_payload

      if self.object_key
        self.object_id = self.request[self.object_key]
      else
        log.info 'unable to find primary key', translation: self
      end
    end

    def retry
      Cangaroo::PerformJobs.call(
        # TODO this should be abstracted away into a interator that accepts json payloads
        json_body: { self.object_type => [ self.request ] }.to_json,
        source_connection: self.source_connection,
        jobs: Rails.configuration.cangaroo.jobs
      )
    end
  end
end

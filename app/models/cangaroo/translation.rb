module Cangaroo
  class Translation < ActiveRecord::Base
    belongs_to :destination_connection, class_name: 'Cangaroo::Connection'
    belongs_to :source_connection, class_name: 'Cangaroo::Connection'

    has_many :attempts

    def successful?
      !!self.response
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

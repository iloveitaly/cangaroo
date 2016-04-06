module Cangaroo
  class Translation < ActiveRecord::Base
    belongs_to :destination_connection, class_name: 'Cangaroo::Connection'
    belongs_to :source_connection, class_name: 'Cangaroo::Connection'

    has_many :attempts

    def successful?
      !!self.response
    end
  end
end

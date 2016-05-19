module Cangaroo
  module Log

    def log
      Cangaroo::Log::Writer.instance
    end

    class Writer < ::SimpleStructuredLogger::Writer
      def expand_context(context)
        expand(context)
      end

      def expand_log(additional_tags)
        expand(additional_tags)
      end

      protected

        def expand(attributes)
          job = attributes.delete(:job)

          if job
            attributes[:job_name] = job.class.to_s
            attributes[:job_id] = job.job_id
            attributes[:connection] = job.class.connection
          end

          translation = attributes.delete(:translation)

          if translation
            attributes[:translation_id] = translation.id
          end

          attempt = attributes.delete(:attempt)

          if attempt
            attributes[:attempt_id] = attempt.id
          end

          attributes
        end
    end

  end
end

require 'charyf'

module Charyf
  module Engine
    module Dispatcher
      class BaseDispatcher < Base

        strategy_name :default

        def self.setup

        end

        def dispatch(request)
          # Find if session exist for this request

          context = Charyf::Engine::Context.new
          context.request = request

          # TODO process session as well
          context.session = session_processor.get.process(request)

          # Get intents
          intents = intent_processors.collect do |processor_klass|
            processor = processor_klass.get_for(context.session ? context.session.skill : nil)

            processor.determine(
                request
            )
          end.collect do |intent|
            [intent, intent.alternatives].flatten
          end.flatten.sort_by do |intent|
            intent.confidence
          end

          # Sort by confidence
          best_match = intents.shift

          # Return best match with alternatives
          if best_match
            best_match.alternatives = intents
            context.intent = best_match
          end

          # TODO
          spawn_controller(context)
        end

      end
    end
  end
end

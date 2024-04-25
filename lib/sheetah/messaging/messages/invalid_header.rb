# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class InvalidHeader < Message
        CODE = "invalid_header"

        def_validator do
          col

          def validate_code_data(message)
            message.code_data.is_a?(String)
          end
        end
      end
    end
  end
end

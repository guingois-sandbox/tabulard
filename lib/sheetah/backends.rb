# frozen_string_literal: true

module Sheetah
  module Backends
    class << self
      def open(*args, backend:, **opts, &block)
        backend.open(*args, **opts, &block)
      end
    end
  end
end

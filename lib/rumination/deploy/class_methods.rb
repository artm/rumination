require_relative "base"

module Rumination
  module Deploy
    module ClassMethods
      def bootstrap target:
        Base.new(target).bootstrap
      end

      def app target:
        Base.new(target).call
      end
    end
  end
end

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

      def env target:
        Base.new(target).env
      end

      def write_env_file target:
        Base.new(target).write_env_file
      end
    end
  end
end

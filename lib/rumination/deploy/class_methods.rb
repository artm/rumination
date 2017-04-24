require_relative "base"

module Rumination
  module Deploy
    module ClassMethods
      def bootstrap target:
        deploy_class.new(target).call do |deploy|
          deploy.bootstrap
        end
      end

      def bootstrap target:
        deploy_class.new(target).bootstrap_undo
      end

      def app target:
        deploy_class.new(target).call
      end

      def env target:
        deploy_class.new(target).env
      end

      def write_env_file target:
        deploy_class.new(target).write_env_file
      end

      def rm_env_file target:
        deploy_class.new(target).rm_env_file
      end

      def deploy_class
        config.deploy_class || Base
      end
    end
  end
end

require_relative "base"

module Rumination
  module Deploy
    module ClassMethods
      def docker_env
        env = {}
        if config.docker_machine
          dm_env_str = `docker-machine env #{config.docker_machine}`
          env = env.merge(Dotenv::Parser.call(dm_env_str))
        end
        env["COMPOSE_FILE"] = config.compose_file if config.compose_file
        env["VIRTUAL_HOST"] = config.virtual_host
        if config.letsencrypt_email.present?
          env["LETSENCRYPT_HOST"] = config.virtual_host
          env["LETSENCRYPT_EMAIL"] = config.letsencrypt_email
        end
        env
      end

      def load_target_config target_name
        load "./config/deploy/targets/#{target_name}.rb"
        self.target = target_name
      rescue LoadError => e
        raise UnknownTarget, e.message
      end

      def bootstrap target:
        deploy_class.new(target).call do |deploy|
          deploy.bootstrap
        end
      end

      def bootstrap_undo target:
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

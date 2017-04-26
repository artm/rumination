require "fileutils"
require "dotenv/parser"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/object/blank"
require_relative "../docker_compose"

module Rumination
  module Deploy
    class Base
      delegate :config, to: Deploy

      private

      def copy_dump_if_requested
        source = config.copy_dumpfile
        return unless source.present?
        return unless File.exists?(source)
        target = Rumination.config.pg.dumpfile_path
        app_container.cp_to_container source, target
      end

      def target_config_path
        (config.target_config_path || "./config/deploy/targets/%s.rb") % target
      end


      def docker_machine_env
        dm_env_str = if config.docker_machine
                       `docker-machine env #{config.docker_machine}`
                     else
                       ""
                     end
        Dotenv::Parser.call(dm_env_str)
      end

      def bootstrapped?
        app_container.has_file?(env_file_path)
      end

      def container(name)
        DockerCompose::Container.new(name)
      end

      def app_container_name
        config.app_countainer || :app
      end

      def app_container
        container(app_container_name)
      end

      def cached_gems?
        target.to_sym == :development
      end
    end
  end
end

require "ostruct"
require "dotenv/parser"
require_relative "../generate"

module Rumination
  module Deploy
    module ClassMethods
      def factory_reset!
        config.clear
        configure do |config|
          config.bootstrap = OpenStruct.new
        end
        self.target = nil
      end

      def docker_env
        env = {}
        if config.docker_machine
          dm_env_str = `docker-machine env #{config.docker_machine}`
          env = env.merge(Dotenv::Parser.call(dm_env_str))
        end
        env["COMPOSE_FILE"] = config.compose_file if config.compose_file.present?
        env["VIRTUAL_HOST"] = config.virtual_host if config.virtual_host.present?
        if config.letsencrypt_email.present?
          env["LETSENCRYPT_HOST"] = config.virtual_host
          env["LETSENCRYPT_EMAIL"] = config.letsencrypt_email
        end
        env = env.merge(config.docker_env || {})
        env
      end

      def load_target_config target_name
        load shared_config_path if File.exists?(shared_config_path)
        load "./config/deploy/targets/#{target_name}.rb"
        self.target = target_name
      rescue LoadError => e
        raise UnknownTarget, e.message
      end

      def development_target?
        self.target.to_s == "development"
      end

      def migrate_on_deploy?
        config.migrate_on_deploy
      end

      def write_env_file path
        File.open(path, "w") do |io|
          persistent_env.merge(generated_passwords).each do |var, val|
            io.puts %Q[export #{var}="#{val}"]
          end
        end
      end

      def files_to_copy_on_bootstrap
        (config.bootstrap && config.bootstrap.copy_files) || []
      end

      def files_to_copy_on_deploy
        config.copy_files || []
      end

      def app_container_name
        config.app_container || :app
      end

      def app_container_full_name
        "#{compose_project_name}_#{app_container_name}_1"
      end

      def compose_project_name
        (ENV["COMPOSE_PROJECT_NAME"] || File.basename(Dir.pwd)).gsub("_","")
      end

      def bootstrapped_flag_path
        "/opt/app/bootstrapped.ok"
      end

      def seeds_dump_file
        "/opt/app/seeds.sql.gz"
      end

      private

      def persistent_env
        config.persistent_env || {}
      end

      def generated_passwords
        password_vars.map{|var| [var, Generate.password]}.to_h
      end

      def password_vars
        config.generate_passwords || Array(config.generate_password)
      end

      def shared_config_path
        "./config/deploy/shared.rb"
      end
    end
  end
end

require "rumination/deploy"

module DeployTasks
  extend Rake::DSL

  class << self
    def app_container_name
      Rumination::Deploy.app_container_name
    end

    def app_container_full_name
      Rumination::Deploy.app_container_full_name
    end

    def bootstrap_db_task
      if defined?(ActiveRecord)
        %w[deploy:bootstrap:db:active_record]
      else
        []
      end
    end
  end

  task :deploy => "deploy:default"

  namespace :deploy do
    task :default => %w[
      setup_docker_env
      copy_nginx_config
      build_containers
      shut_down_services
      refresh_gems_in_development
      migrate_if_requested
      start_services
      copy_files
      on:deployed
    ]

    task :bootstrap => %w[
      setup_docker_env
      copy_nginx_config
      build_containers
      shut_down_services
      refresh_gems_in_development
      start_services
      bootstrap:check_flag
      bootstrap:env_file
      bootstrap:copy_files
      bootstrap:db
      copy_files
      on:bootstrapped
      on:deployed
      bootstrap:flag_success
    ]

    namespace :on do
      task :deployed => :publish_static
      task :bootstrapped
    end

    task :publish_static do
      vhosts = ENV["VIRTUAL_HOST"].to_s.split(",")
      if vhosts.any? && Dir.exists?("./public")
        main_vhost = vhosts.shift
        sh "docker-compose run --rm #{app_container_name} rsync -av public/ /var/www/#{main_vhost}"
        vhosts.each do |vhost|
          sh "docker-compose run --rm #{app_container_name} ln -fs /var/www/#{main_vhost} /var/www/#{vhost}"
        end
      end
    end

    task :copy_nginx_config do
      vhosts = ENV["VIRTUAL_HOST"].to_s.split(",")
      if vhosts.any? && File.exists?("./config/deploy/nginx.conf")
        main_vhost = vhosts.shift
        sh "docker-compose run --rm #{app_container_name} rsync -av config/deploy/nginx.conf /etc/nginx/vhost.d/#{main_vhost}"
        vhosts.each do |vhost|
          sh "docker-compose run --rm #{app_container_name} ln -fs /etc/nginx/vhost.d/#{main_vhost} /etc/nginx/vhost.d/#{vhost}"
        end
      end
    end

    namespace :bootstrap do
      task :env_file do
        env_file_path = "/opt/app/env"
        temp_file_path = "tmp/#{Rumination::Deploy.target}.env"
        mkdir_p File.dirname(temp_file_path)
        Rumination::Deploy.write_env_file(temp_file_path)
        sh "docker cp #{temp_file_path} #{app_container_full_name}:#{env_file_path}"
      end

      task :copy_files do
        Rumination::Deploy.files_to_copy_on_bootstrap.each do |source, target|
          sh "docker cp #{source} #{app_container_full_name}:#{target}"
        end
      end

      task :db => bootstrap_db_task

      task "db:active_record" do
        sh "docker-compose run --rm #{app_container_name} rake db:setup:maybe_load_dump"
      end

      task :flag_success do
        flag_path = Rumination::Deploy.bootstrapped_flag_path
        sh "docker-compose run --rm #{app_container_name} touch #{flag_path}"
      end

      task :check_flag do
        flag_path = Rumination::Deploy.bootstrapped_flag_path
        sh "docker-compose run --rm #{app_container_name} test -f #{flag_path}" do |ok, err|
          if ok
            message = "The target '#{Rumination::Deploy.target}' was bootstrap already"
            raise Rumination::Deploy::BootstrappedAlready, message
          end
        end
      end

      task :undo => %w[confirm_undo setup_docker_env] do
        sh "docker-compose down --remove-orphans -v"
      end

      task :confirm_undo do
        require "highline/import"
        question = "Do you really want to undo the bootstrap (database will be dropped)?"
        abort("Bootstrap undo canceled, you didn't mean it") unless agree(question)
      end
    end

    task :build_containers do
      sh "docker-compose build"
    end

    task :shut_down_services do
      sh "docker-compose down --remove-orphans"
    end

    task :refresh_gems_in_development do
      if Rumination::Deploy.development_target?
        sh "docker-compose run --rm #{app_container_name} bundle install"
      end
    end

    task :migrate_if_requested do
      if Rumination::Deploy.migrate_on_deploy?
        sh "docker-compose run --rm #{app_container_name} rake db:migrate"
      end
    end

    task :start_services do
      sh "docker-compose up -d"
    end

    task :copy_files do
      Rumination::Deploy.files_to_copy_on_deploy.each do |source, target|
        sh "docker cp #{source} #{app_container_full_name}:#{target}"
      end
    end
  end
end

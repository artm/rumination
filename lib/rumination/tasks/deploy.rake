require "rumination/deploy"

module DeployTasks
  extend Rake::DSL

  task :deploy => "deploy:default"

  namespace :deploy do
    task :default => %w[
      start
      finish
    ]

    task :bootstrap => %w[
      start
      bootstrap:check_flag
      bootstrap:env_file
      bootstrap:copy_files
      bootstrap:db
      on:bootstrapped
      finish
      bootstrap:flag_success
    ]

    namespace :on do
      task :deployed
      task :bootstrapped
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

      task :db

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

    task :start => %w[
      setup_docker_env
      switch_containers
    ]

    task :finish => %w[
      copy_files
      on:deployed
    ]

    task :switch_containers => %w[
      build_containers
      shut_down_services
      start_services
    ]

    task :build_containers do
      sh "docker-compose build"
    end

    task :shut_down_services do
      sh "docker-compose down --remove-orphans"
    end

    task :start_services do
      if Rumination::Deploy.development_target?
        sh "docker-compose run --rm #{app_container_name} bundle install"
      end
      sh "docker-compose up -d"
    end

    task :copy_files do
      Rumination::Deploy.files_to_copy_on_deploy.each do |source, target|
        sh "docker cp #{source} #{app_container_full_name}:#{target}"
      end
    end
  end

  class << self
    def app_container_name
      Rumination::Deploy.app_container_name
    end

    def app_container_full_name
      Rumination::Deploy.app_container_full_name
    end
  end
end

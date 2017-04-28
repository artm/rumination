require "rumination/deploy"
require "dotenv"
require "active_support/core_ext/string/strip"

task :deploy, [:target] => "deploy:default"

namespace :deploy do
  task :default, [:target] => %w[
    start
    finish
  ]

  task :bootstrap, [:target] => %w[
    start
    bootstrap:check_flag
    bootstrap:env_file
    bootstrap:copy_files
    bootstrap:db
    on:bootstrapped
    finish
    bootstrap:flag_success
  ]

  task :env, [:target] => :load_target_config_filterd do |t, args|
    puts
    Rumination::Deploy.docker_env.each do |var, val|
      puts %Q[export #{var}="#{val}"]
    end
    puts <<-__.strip_heredoc
      # to load this into a bash environment run:
      #
      #   eval $(rake deploy:env[#{Rumination::Deploy.target}])
    __
  end

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
      container = Rumination::Deploy.app_container_full_name
      sh "docker cp #{temp_file_path} #{container}:#{env_file_path}"
    end

    task :copy_files do
      container = Rumination::Deploy.app_container_full_name
      Rumination::Deploy.files_to_copy_on_bootstrap.each do |source, target|
        sh "docker cp #{source} #{container}:#{target}"
      end
    end

    task :db

    task :flag_success do
      container = Rumination::Deploy.app_container_name
      flag_path = Rumination::Deploy.bootstrapped_flag_path
      sh "docker-compose run --rm #{container} touch #{flag_path}"
    end

    task :check_flag do
      container = Rumination::Deploy.app_container_name
      flag_path = Rumination::Deploy.bootstrapped_flag_path
      sh "docker-compose run --rm #{container} test -f #{flag_path}" do |ok, err|
        raise Rumination::Deploy::BootstrappedAlready, "The target '#{Rumination::Deploy.target}' was bootstrap already"
      end
    end

    task :undo, [:target] => %w[confirm_undo] do |t, args|
      sh "docker-compose down --remove-orphans -v"
    end

    task :confirm_undo do |t, args|
      require "highline/import"
      question = "Do you really want to undo the bootstrap (database will be dropped)?"
      abort("Bootstrap undo canceled, you didn't mean it") unless agree(question)
    end
  end

  task :setup_docker_env, [:target] => :load_target_config do |t, args|
    puts "Setting up '#{Rumination::Deploy.target}' target docker environment"
    Dotenv.load
    ENV.update Rumination::Deploy.docker_env
  end

  task :load_target_config, [:target] do |t, args|
    args.with_defaults target: :development
    puts "Loading '#{args.target}' target config"
    Rumination::Deploy.load_target_config args.target
  end

  task :load_target_config_filterd, [:target] do |t, args|
    with_hash_puts do
      Rake::Task["deploy:load_target_config"].invoke args.target
    end
  end

  task :start, [:target] => %w[
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
    sh "docker-compose up -d"
  end

  task :copy_files do
    container = Rumination::Deploy.app_container_full_name
    Rumination::Deploy.files_to_copy_on_deploy.each do |source, target|
      sh "docker cp #{source} #{container}:#{target}"
    end
  end
end

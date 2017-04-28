require "dotenv"
require "active_support/core_ext/string/strip"

task :deploy, [:target] => "deploy:default"

namespace :deploy do
  task :default, [:target] => %w[
    setup_docker_env
    prepare_containers
    on:deployed
  ]

  task :bootstrap, [:target] => %w[
    setup_docker_env
    prepare_containers
    bootstrap:env_file
    bootstrap:copy_files
    bootstrap:db
    on:bootstrapped
    on:deployed
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
      Rumination::Deploy.bootstrap_copy_files.each do |source, target|
        sh "docker cp #{source} #{container}:#{target}"
      end
    end

    task :db

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

  task :prepare_containers => %w[
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
end

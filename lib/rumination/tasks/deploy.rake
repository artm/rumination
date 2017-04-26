task :deploy, [:target] => "deploy:default"

namespace :deploy do
  task :env, [:target] => :load_target_config_filterd do |t, args|
    puts
    Rumination::Deploy.docker_env.each do |var, val|
      puts %Q[export #{var}="#{val}"]
    end
    puts <<-__

# to load this into a bash environment run:
#
#   eval $(rake deploy:env[#{Rumination::Deploy.target}])

    __
  end

  task :default, [:target] => :setup_docker_env do |t, args|
  end

  task :bootstrap, [:target] => :setup_docker_env do |t, args|
  end

  task :setup_docker_env, [:target] => :load_target_config do |t, args|
    puts "Setting up '#{Rumination::Deploy.target}' target docker environment"
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

  namespace :bootstrap do
    task :undo, [:target] => %w[confirm_undo] do |t, args|
    end

    task :confirm_undo do |t, args|
      require "highline/import"
      question = "Do you really want to undo the bootstrap (database will be dropped)?"
      abort("Bootstrap undo canceled, you didn't mean it") unless agree(question)
    end
  end
end

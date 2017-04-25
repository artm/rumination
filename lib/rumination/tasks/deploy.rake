task :deploy, [:target] => "deploy:default"

namespace :deploy do
  task :env, [:target] => [:puts_comments, :load_target_config] do |t, args|
    Rumination::Deploy.docker_env.each do |var, val|
      puts %Q[export #{var}="#{val}"]
    end
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

  tasks :puts_comments do
    alias_method :old_puts, :puts
    def puts *args
      print "# "
      old_puts *args
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

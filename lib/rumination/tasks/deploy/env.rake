require "dotenv"
require "active_support/core_ext/string/strip"

require "rumination/deploy"

namespace :deploy do
  task :env => :load_target_config_filterd do
    puts
    Rumination::Deploy.docker_env.each do |var, val|
      puts %Q[export #{var}="#{val}"]
    end
    puts <<-__.strip_heredoc
      # to load this into a bash environment run:
      #
      #   eval "$(rake deploy:env[#{Rumination::Deploy.target}])"
      #
      # Quotes aren't optional
    __
  end

  task :load_target_config do
    target = ENV["TARGET"] || "development"
    puts "Loading '#{target}' target config"
    Rumination::Deploy.load_target_config target
  end

  task :load_target_config_filterd do
    require "rumination/utils/with_hash_puts"
    with_hash_puts do
      Rake::Task["deploy:load_target_config"].invoke
    end
  end

  task :setup_docker_env => :load_target_config do
    puts "Setting up '#{Rumination::Deploy.target}' target docker environment"
    Dotenv.load
    ENV.update Rumination::Deploy.docker_env
  end
end

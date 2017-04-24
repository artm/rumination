namespace :deploy do
  task :bootstrap, [:target] do |t, args|
    require "rumination/deploy"
    args.with_defaults target: :development
    begin
      Rumination::Deploy.bootstrap(target: args.target)
    rescue Rumination::Deploy::BootstrappedAlready
      abort "'#{args.target}' has already been bootstrapped"
    end
  end

  namespace :bootstrap do
    task :undo, [:target] => %w[confirm_undo] do |t, args|
      require "rumination/deploy"
      args.with_defaults target: :development
      begin
        Rumination::Deploy.bootstrap_undo(target: args.target)
      rescue Rumination::Deploy::NotBootstrappedYet
        abort "'#{args.target}' has not been bootstrapped yet"
      end
    end

    task :confirm_undo, [:target] do |t, args|
      require "highline/import"
      question = "Do you really want to undo the bootstrap (database will be dropped)?"
      abort("Bootstrap undo canceled, you didn't mean it") unless agree(question)
    end
  end
end

namespace :deploy do
  task :bootstrap, [:target] do |t, args|
    args.with_defaults target: :development
    begin
      Rumination::Deploy.bootstrap(target: args.target)
    rescue Rumination::Deploy::BootstrappedAlready
      abort "'#{args.target}' has already been bootstrapped"
    end
  end

  namespace :bootstrap do
    # these are invoked inside the containers
    task :inside, [:target] => %w[write_env_file db:setup:maybe_load_dump]

    task :write_env_file, [:target] do |t, args|
      Rumination::Deploy.write_env_file(target: args.target)
    end
  end
end

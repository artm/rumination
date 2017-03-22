namespace :deploy do
  task :bootstrap, [:target] do |t, args|
    args.with_defaults target: :development
    begin
      Rumination::Deploy.bootstrap(target: args.target)
    rescue Rumination::Deploy::BootstrappedAlready
      abort "'#{args.target}' has already been bootstrapped"
    end
  end
end


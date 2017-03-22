task :deploy, [:target] do |t, args|
  args.with_defaults target: :development
  Rumination::Deploy.app(target: args.target)
end

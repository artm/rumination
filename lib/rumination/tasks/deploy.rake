task :deploy, [:target] do |t, args|
  require "rumination/deploy"
  args.with_defaults target: :development
  Rumination::Deploy.app(target: args.target)
end

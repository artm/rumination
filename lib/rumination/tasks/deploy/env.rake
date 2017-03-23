namespace :deploy do
  task :env, [:target] do |t, args|
    args.with_defaults target: :development
    Rumination::Deploy.env(target: args.target).each do |var, val|
      puts %Q[export #{var}="#{val}"]
    end
  end
end

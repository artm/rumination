namespace :db do
  namespace :setup do
    task :maybe_load_dump do
      continue = if File.exists?(Rumination.config.pg.dumpfile_path)
                   :create_load_seed
                 else
                   :setup
                 end
      Rake::Task[continue].invoke
    end

    task :create_load_seed => [:create, :load_dump, :migrate, :seed]
  end
end

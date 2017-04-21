namespace :db do
  namespace :setup do
    task :maybe_load_dump do
      require "rumination"
      continue = if File.exists?(Rumination.config.pg.dumpfile_path)
                   "db:setup:create_load_seed"
                 else
                   "db:setup"
                 end
      Rake::Task[continue].invoke
    end

    task :create_load_seed => [:create, :load_dump, :migrate, :seed]
  end
end

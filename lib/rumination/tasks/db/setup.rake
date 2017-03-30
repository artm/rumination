namespace :db do
  namespace :setup do
    if File.exists?(Rumination.config.pg.dumpfile_path)
      task :maybe_load_dump => [:create, :load_dump, :migrate, :seed]
    else
      task :maybe_load_dump => :setup
    end
  end
end

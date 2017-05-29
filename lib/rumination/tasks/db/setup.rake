namespace :db do
  namespace :setup do
    task :maybe_load_dump do
      require "rumination"
      path = Rumination::Deploy.seeds_dump_file
      if File.exists?(path)
        Rake::Task["db:setup:create_load_seed"].invoke path
      else
        "db:setup"
        Rake::Task["db:setup"].invoke
      end
    end

    task :create_load_seed, [:dumpfile_path] => [:create, :load_dump, :migrate, :seed]
  end
end

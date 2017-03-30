namespace :db do
  def dump_path
    "db/postgres_dumps/seeds.sql.gz"
  end

  namespace :setup do
    if File.exists?(dump_path)
      task :maybe_load_dump => [:create, :load_dump, :migrate, :seed]
    else
      task :maybe_load_dump => :setup
    end
  end
end

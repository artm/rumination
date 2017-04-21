namespace :db do
  require "rumination"
  include Rumination::Pg::Commands

  task :create_dump, [:dumpfile_path] => :pg_environment do |t, args|
    args.with_defaults dumpfile_path: Rumination.config.pg.dumpfile_path
    create_dump args.dumpfile_path, "-O"
  end

  task :load_dump, [:dumpfile_path] => :pg_environment do |t, args|
    args.with_defaults dumpfile_path: Rumination.config.pg.dumpfile_path
    load_dump args.dumpfile_path
  end

  task :pg_environment => :environment do
    db_config = Rails.configuration.database_configuration[Rails.env]
    ENV["PGHOST"]     = db_config["host"].to_s     if db_config["host"]
    ENV["PGPORT"]     = db_config["port"].to_s     if db_config["port"]
    ENV["PGPASSWORD"] = db_config["password"].to_s if db_config["password"]
    ENV["PGUSER"]     = db_config["username"].to_s if db_config["username"]
    ENV["PGDATABASE"] = db_config["database"].to_s if db_config["database"]
  end
end

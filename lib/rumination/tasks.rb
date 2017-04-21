Dir[File.expand_path("../tasks/**/*.rake", __FILE__)].each do |task_file|
  load task_file
end

Dir[File.expand_path("../tasks/**/*.rake", __FILE__)].each do |task_file|
  import task_file
end

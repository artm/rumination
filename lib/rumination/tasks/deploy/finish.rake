namespace :deploy do
  task :unload, [:target] do |t, args|
    vhost = ENV["VIRTUAL_HOST"]
    if vhost.present?
      sh "rm -f /etc/nginx/vhost.d/#{vhost}*"
    end
  end

  task :finish, [:target] => %w[static_files vhost_conf]

  task :static_files, [:target] do |t, args|
    vhost = ENV["VIRTUAL_HOST"]
    if vhost
      sh "rsync -av public/ /var/www/#{vhost}"
    end
  end

  task :vhost_conf, [:target] do |t, args|
    def erb_config basename, vhost
      template = "config/nginx/vhost.d/#{basename}.erb"
      if vhost && File.exists?(template)
        new_name = basename.sub("app", vhost)
        sh "erb #{template} > /etc/nginx/vhost.d/#{new_name}"
      end
    end
    vhost = ENV["VIRTUAL_HOST"]
    erb_config "app", vhost
    erb_config "app_location", vhost
  end
end

namespace :docker do

  docker_tasks docker_container_name, image = docker_image_name

  task :build => config.config_files do
    docker_build image
  end

  task :start do
    puts "Admin user: #{config.username}, password: #{config.password}"
  end

end

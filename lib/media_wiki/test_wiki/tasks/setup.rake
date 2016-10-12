namespace :setup do

  docker_tasks name = docker_container_name(true), image = docker_image_name(true)

  task :config_files do
    touch config.config_files
  end

  task build: [:config_files, *config.build_files] do
    docker_build image
  end

  task config: :start do
    url, cfg = docker_url(name), config.config_files.first

    broken, args = broken_version?(ENV['STRICTVERSION']),
      ["#{url}/mw-config/", config.data_path, cfg]

    !verified_version?(ENV['STRICTVERSION']) ?
      broken ? setup_broken(cfg) : setup_manual(*args << nil << true) :
    begin
      require 'mechanize'
    rescue LoadError => err
      broken ? setup_broken(err) : setup_manual(*args << err)
    else ENV['NOMECHANIZE'] ?
      broken ? setup_broken(nil) : setup_manual(*args) : setup_mechanize(*args)
    end

    fix_config(cfg, File.basename(url))
  end

  task dump: :config do
    path = File.join(docker_volume(name),
      config.data_directory, config.database_file)

    args = %W[sqlite3 -batch -cmd .mode\ insert -cmd .dump #{path} .exit]
    args.unshift('sudo') unless ENV['NOSUDO']

    File.write(config.config_files.last, IO.popen(args, &:read).chomp)
  end

  task setup: [:build, :config]

  task export: [:dump, :clean]

end

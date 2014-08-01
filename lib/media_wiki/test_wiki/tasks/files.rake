require 'rake/clean'
require 'erb'

directory config.build_path

config.config_files = {
  setup: 'LocalSettings.php', export: config.dump_file
}.map { |task, file|
  File.join(config.build_path, file).tap { |path|
    file_size(path => config.build_path) { |t|
      t.enhance(["setup:#{task}"]) if t.needed?
    }
  }
}

config.build_files = FileList[
  File.join(config.template_path, "*#{ext = '.erb'}")
].map { |template|
  File.join(config.build_path, File.basename(template, ext)).tap { |path|
    file(path => template) {
      File.write(path, ERB.new(File.read(template)).result(binding))
      File.chmod(File.stat(template).mode, path)
    }
  }
}

CLEAN.include(*config.build_files)
CLOBBER.include(config.build_path)

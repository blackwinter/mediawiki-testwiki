require File.expand_path(%q{../lib/media_wiki/test_wiki/version}, __FILE__)

begin
  require 'hen'

  Hen.lay! {{
    gem: {
      name:         %q{mediawiki-testwiki},
      version:      MediaWiki::TestWiki::VERSION,
      summary:      %q{MediaWiki test wikis based on Docker.},
      description:  %q{Provides pre-configured MediaWiki wikis as Docker images.},
      author:       %q{Jens Wille},
      email:        %q{jens.wille@gmail.com},
      license:      %q{AGPL-3.0},
      homepage:     :blackwinter,
      dependencies: { docker_helper: ['~> 0.0', '>= 0.0.2'] },
      requirements: %w[docker.io sqlite3\ (development)],
      extra_files:  FileList['lib/**/*.rake'].to_a,

      development_dependencies: { mechanize: '~> 2.7' },

      required_ruby_version: '>= 1.9.3'
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end

__END__
# If we were to import the Docker tasks into this Rakefile,
# we'd do it like this:

require 'media_wiki/test_wiki/rake_helper'

MediaWiki::TestWiki::RakeHelper.configure(self, true) { |config|
  config.root_path = File.expand_path('../docker', __FILE__)
}

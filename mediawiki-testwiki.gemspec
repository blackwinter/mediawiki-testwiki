# -*- encoding: utf-8 -*-
# stub: mediawiki-testwiki 0.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "mediawiki-testwiki"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jens Wille"]
  s.date = "2014-09-26"
  s.description = "Provides pre-configured MediaWiki wikis as Docker images."
  s.email = "jens.wille@gmail.com"
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["COPYING", "ChangeLog", "README", "Rakefile", "lib/media_wiki/test_wiki.rb", "lib/media_wiki/test_wiki/config.rb", "lib/media_wiki/test_wiki/docker_helper.rb", "lib/media_wiki/test_wiki/docker_pool.rb", "lib/media_wiki/test_wiki/rake_helper.rb", "lib/media_wiki/test_wiki/rake_tasks.rb", "lib/media_wiki/test_wiki/rspec_adapter.rb", "lib/media_wiki/test_wiki/tasks/docker.rake", "lib/media_wiki/test_wiki/tasks/files.rake", "lib/media_wiki/test_wiki/tasks/main.rake", "lib/media_wiki/test_wiki/tasks/setup.rake", "lib/media_wiki/test_wiki/version.rb", "lib/mediawiki-testwiki.rb"]
  s.homepage = "http://github.com/blackwinter/mediawiki-testwiki"
  s.licenses = ["AGPL-3.0"]
  s.post_install_message = "\nmediawiki-testwiki-0.0.1 [2014-09-26]:\n\n* First release.\n\n"
  s.rdoc_options = ["--title", "mediawiki-testwiki Application documentation (v0.0.1)", "--charset", "UTF-8", "--line-numbers", "--all", "--main", "README"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.requirements = ["docker.io", "sqlite3 (development)"]
  s.rubygems_version = "2.4.1"
  s.summary = "MediaWiki test wikis based on Docker."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<docker_helper>, ["~> 0.0.2"])
      s.add_development_dependency(%q<mechanize>, ["~> 2.7.3"])
      s.add_development_dependency(%q<hen>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<docker_helper>, ["~> 0.0.2"])
      s.add_dependency(%q<mechanize>, ["~> 2.7.3"])
      s.add_dependency(%q<hen>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<docker_helper>, ["~> 0.0.2"])
    s.add_dependency(%q<mechanize>, ["~> 2.7.3"])
    s.add_dependency(%q<hen>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end

#--
###############################################################################
#                                                                             #
# mediawiki-testwiki -- MediaWiki test wiki based on Docker                   #
#                                                                             #
# Copyright (C) 2014 Jens Wille                                               #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@gmail.com>                                       #
#                                                                             #
# mediawiki-testwiki is free software; you can redistribute it and/or modify  #
# it under the terms of the GNU Affero General Public License as published by #
# the Free Software Foundation; either version 3 of the License, or (at your  #
# option) any later version.                                                  #
#                                                                             #
# mediawiki-testwiki is distributed in the hope that it will be useful, but   #
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY  #
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public      #
# License for more details.                                                   #
#                                                                             #
# You should have received a copy of the GNU Affero General Public License    #
# along with mediawiki-testwiki. If not, see <http://www.gnu.org/licenses/>.  #
#                                                                             #
###############################################################################
#++

require_relative 'docker_helper'

module MediaWiki

  module TestWiki

    module RakeHelper

      include DockerHelper

      class << self

        def extended(base)
          keep = [:noop, :verbose]

          base.define_singleton_method(:docker_system) { |*args, &block|
            options = !args.last.is_a?(Hash) ? {} :
              args.pop.keep_if { |k,| keep.include?(k) }

            sh(*args << options, &block)
          }

          configure(base) unless base.respond_to?(:config)
        end

        def configure(base, load_tasks = false, &block)
          Config.enhance(base, &block).tap {
            require_relative 'rake_tasks' if load_tasks
          }
        end

      end

      def docker_tasks(name, image)
        %w[start stop restart clean clobber].each { |task|
          task(task) { send("docker_#{task}", name, image) }
        }

        task(:start) { puts "#{name}: #{docker_url(name)}" }
      end

      def file_size(*args)
        file_create(*args) { |t| File.write(t.name, '') }.instance_eval {
          def needed?; !File.size?(name); end
          yield self if block_given?
          self
        }
      end

      def fix_config(file, host)
        File.write(file, File.read(file).tap { |content|
          content.sub!(/^\$wgServer\b/, '#\&')
          content.gsub!(host, 'localhost')
        })
      end

      def setup_broken(arg)
        msg = <<-EOT

*** Manual configuration is broken for this MediaWiki version. ***

        EOT

        if arg.is_a?(LoadError)
          abort msg << <<-EOT
However, automatic configuration is not available: #{arg}.
Please install the `mechanize' gem and try again.
          EOT
        elsif arg
          wait msg << <<-EOT
Also, automatic configuration is not supported for this version either.
Please create a valid configuration file and press enter when finished:
#{arg}
          EOT
        else
          abort msg << <<-EOT
However, you have requested to skip automatic configuration.
Please unset `NOMECHANIZE' and try again.
          EOT
        end
      end

      def setup_manual(url, dir, cfg, err = nil, unk = nil)
        msg = <<-EOT

Visit #{url} and configure the wiki:
        EOT

        msg << <<-EOT if unk

NOTE: These configuration instructions have not been verified for
      this version of MediaWiki -- please use your own judgement!
        EOT

        msg << <<-EOT

  - Language
    - Continue

  - Welcome to MediaWiki!
    - Continue

  - Connect to database
    - Database type: SQLite
    - SQLite data directory: #{dir}
    - Database name: #{config.database_name}
    - Continue

  - Name
    - Name of wiki: #{config.sitename}
    - Your username: #{config.username}
    - Password: #{config.password}
    - Password again: #{config.password}
    - I'm bored already, just install the wiki.
    - Continue

  - Install (1)
    - Continue

  - Install (2)
    - Continue

Save #{File.basename(cfg)} (replace existing file if already present):
#{cfg}

Close configuration window and press enter when finished.
        EOT

        msg << <<-EOT if err

NOTE: Install the `mechanize' gem to automate this process. (#{err})
        EOT

        wait(msg)
      end

      def setup_mechanize(url, dir, cfg)
        agent = Mechanize.new
        page  = agent.get(url)

        continue = lambda { |&block|
          form = page.forms.first
          block[form] if block
          page = agent.submit(form)
        }

        2.times { continue.() }

        continue.() { |form|
          form.sqlite_wgSQLiteDataDir = dir
          form.sqlite_wgDBname = config.database_name
          form.radiobuttons_with(value: 'sqlite').first.check
        }

        continue.() { |form|
          form.radiobuttons_with(value: 'skip').first.check

          form.config_wgSitename = config.sitename
          form.config__AdminName = config.username

          form.config__AdminPassword  = config.password
          form.config__AdminPassword2 = config.password
        }

        2.times { continue.() }

        page.link_with(text: Regexp.new(
          Regexp.escape(File.basename(cfg)))).click.save!(cfg)
      end

      def verified_version?(strict = false, list = config.verified_versions)
        strict ? list.include?(config.version) :
          list.grep(/\A#{Regexp.escape(config.version[/.*\./])}/).any?
      end

      def broken_version?(strict = false)
        verified_version?(strict, config.broken_versions)
      end

      private

      def wait(msg)
        puts(msg)
        $stdin.gets
      end

    end

  end

end

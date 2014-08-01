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

module MediaWiki

  module TestWiki

    class Config

      class << self

        def enhance(base, &block)
          base.singleton_class.send(:attr_accessor, :config)
          base.config = new(&block)
          base
        end

        private

        def attribute(name, options = {}, &block)
          define_setter(name, setter = "#{name}=")
          define_getter(name, setter, options[:env], &block)
        end

        def define_setter(name, setter)
          define_method(setter) { |value|
            singleton_class.class_eval { attr_reader name }
            instance_variable_set("@#{name}", value)
          }
        end

        def define_getter(name, setter, env, &block)
          if env
            raise ArgumentError, 'no block given' unless block

            define_method(name) { send(setter,
              ENV.fetch("#{env}_#{name}".upcase) { instance_eval(&block) }) }
          elsif block
            define_method(name) { send(setter, instance_eval(&block)) }
          else
            define_method(name) { raise ConfigNotSetError.new(name) }
          end
        end

      end

      # :section: Download

      ##
      # Base location for tarball downloads
      # (Must exist and be accessible for download)
      attribute :download_base, env: :mediawiki do
        'https://releases.wikimedia.org/mediawiki'
      end

      ##
      # Full download URL
      attribute :download_url, env: :mediawiki do
        File.join(download_base, version[/\d+\.\d+/], install_file)
      end

      # :section: Versions

      ##
      # Version numbers for which configuration instructions have been verified
      # (Must match version numbers from #download_base)
      attribute :verified_versions do
        %w[1.23.4 1.22.11 1.21.11 1.20.8 1.19.19 1.18.6 1.17.5]
      end

      ##
      # Version numbers for which manual configuration is broken
      # (Must match version numbers from #download_base)
      attribute :broken_versions do
        %w[1.17.5]
      end

      ##
      # Version number to install
      # (Must match a version number from #download_base)
      attribute :version, env: :mediawiki do
        ENV.fetch('VERSION') { verified_versions.first }
      end

      # :section: Registry

      ##
      # User name for image
      # (Arbitrary string; used for registry)
      attribute :registry_user, env: :docker do
        git_config('github.user')
      end

      ##
      # Repository name for image
      # (Arbitrary string; used for registry)
      attribute :registry_repo, env: :docker do
        'mediawiki-testwiki'
      end

      ##
      # Maintainer of image
      # (Arbitrary string; used for author field)
      attribute :maintainer, env: :docker do
        "#{git_config('user.name')} <#{git_config('user.email')}>"
      end

      # :section: Wiki

      ##
      # Site name for wiki
      # (Arbitrary string)
      attribute :sitename, env: :mediawiki do
        'MW-Test'
      end

      ##
      # User name for wiki
      # (Arbitrary string)
      attribute :username, env: :mediawiki do
        sitename
      end

      ##
      # Password for wiki
      # (Arbitrary string; must not match #username)
      attribute :password, env: :mediawiki do
        'mw_test'
      end

      ##
      # Endpoint to talk to
      # (Must match MediaWiki endpoint)
      attribute :endpoint, env: :mediawiki do
        '/api.php'
      end

      # :section: Image paths

      ##
      # Name of installation directory inside image (relative to #volume)
      # (Must match directory extracted from tarball)
      attribute :install_directory, env: :mediawiki do
        "mediawiki-#{version}"
      end

      ##
      # :category: Internal
      #
      # Path to installation directory inside image (absolute)
      attribute :install_path do
        File.join(volume, install_directory)
      end

      ##
      # :category: Internal
      #
      # Name of installation file inside image
      attribute :install_file do
        "#{install_directory}.tar.gz"
      end

      ##
      # Name of data directory inside image (relative to #volume)
      # (Arbitrary string)
      attribute :data_directory do
        'data'
      end

      ##
      # :category: Internal
      #
      # Path to data directory inside image (absolute)
      attribute :data_path do
        File.join(volume, data_directory)
      end

      # :section: Database

      ##
      # Name of database
      # (Arbitrary string)
      attribute :database_name do
        'mw_test'
      end

      ##
      # :category: Internal
      #
      # Name of database file
      attribute :database_file do
        "#{database_name}.sqlite"
      end

      ##
      # :category: Internal
      #
      # Path to database file inside image (absolute)
      attribute :database_path do
        File.join(data_path, database_file)
      end

      ##
      # :category: Internal
      #
      # Name of dump file
      attribute :dump_file do
        "#{database_name}.sql"
      end

      ##
      # :category: Internal
      #
      # Path to dump file inside image (absolute)
      attribute :dump_path do
        File.join(data_path, dump_file)
      end

      # :section: Image

      ##
      # Name of base directory inside image (will be exported)
      # (Must be an absolute path)
      attribute :volume do
        '/srv'
      end

      ##
      # Path to PHP-FPM listen socket inside image
      # (Must be an absolute path)
      attribute :php_fpm_socket do
        '/var/run/php5-fpm.sock'
      end

      ##
      # Port to serve content from inside image (will be exposed)
      # (Arbitrary integer)
      attribute :port do
        80
      end

      # :section: Process

      ##
      # User to run process as inside image
      # (Must match actual system user)
      attribute :process_user do
        'www-data'
      end

      ##
      # Group to run process as inside image
      # (Must match actual system group)
      attribute :process_group do
        process_user
      end

      # :section: Host paths

      ##
      # Path to root directory containing #template_path and #build_path
      attribute :root_path do
        File.expand_path(File.dirname(Rake.application.rakefile))
      end

      ##
      # Path to template directory on host
      # (Must contain build file templates <tt>*.erb</tt>)
      attribute :template_path do
        File.join(root_path, 'templates')
      end

      ##
      # Path to build directory on host
      # (Should be empty; used as build context)
      attribute :build_path do
        unless File.writable?(base = root_path)
          require 'tmpdir'
          base = [Dir.tmpdir, "#{registry_repo}-docker"]
        end

        File.join(base, 'builds', version)
      end

      ##
      # :category: Internal
      #
      # List of build files
      attribute :build_files

      ##
      # :category: Internal
      #
      # List of config files
      attribute :config_files

      # :section:

      def initialize
        yield self if block_given?
      end

      private

      def git_config(key)
        %x{git config #{key}}.chomp
      end

      class ConfigNotSetError < RuntimeError

        def initialize(name)
          @name = name
        end

        def to_s
          "Configuration not set: #{@name}"
        end

      end

    end

  end

end

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

require 'docker_helper'

require_relative 'config'

module MediaWiki

  module TestWiki

    module DockerHelper

      include ::DockerHelper

      def self.docker(silent = false, &block)
        ::DockerHelper::Proxy.new.extend(self).tap { |docker|
          docker.extend(SilentDocker) if silent
          Config.enhance(docker, &block)
        }
      end

      def docker_container_name(setup = false)
        parts = [config.registry_repo, config.version]
        parts << :setup if setup
        parts.join('-')
      end

      def docker_image_name(setup = false)
        base = "#{config.registry_repo}:#{config.version}"
        setup ? "#{base}-setup" : "#{config.registry_user}/#{base}"
      end

      def docker_build(image = nil)
        super(config.build_path, image)
      end

      def docker_volume(name = nil)
        super(config.volume, name)
      end

      def docker_url(*args)
        args.size > 1 ? super : super(config.port, *args)
      end

      module SilentDocker

        def docker_system(*args, &block)
          options = args.last.is_a?(Hash) ? args.pop : {}
          options[:out] = options[:err] = :close
          super(*args << options, &block)
        end

      end

    end

  end

end

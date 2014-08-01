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

require_relative 'docker_pool'

module MediaWiki

  module TestWiki

    module RSpecAdapter

      Proxy = Struct.new(:version, :config, :pool)

      PROXY_NAME = :live_media_wiki

      class << self

        def enhance(config, *args)
          return if config.respond_to?(PROXY_NAME)
          init_config(Proxy.new, config, *args)
          config
        end

        def extended(base)
          init_proxy(RSpec.configuration.send(PROXY_NAME), base.metadata)
          base
        end

        private

        def init_config(mw, config, *args)
          config.add_setting PROXY_NAME, default: mw

          config.after   :context, *args do mw.pool.clean end
          config.extend  self,     *args
          config.include Helpers,  *args

          config.filter_run_excluding required_version: lambda { |value|
            version = mw.version and not
              Gem::Requirement.new(Array(value)).satisfied_by?(version)
          }
        end

        def init_proxy(mw, options = {})
          version, size = options.values_at(:version, :pool_size)

          mw.pool = DockerPool.new(size, nil, true) { |config|
            mw.version = Gem::Version.new(config.version = version) if version
            mw.config = { username: config.username, password: config.password }
          }
        end

      end

      module Helpers

        def live_media_wiki_gateway(*args)
          described_class.new(@live_media_wiki_url, *args).tap { |gateway|
            yield gateway if block_given?
          }
        end

        def live_media_wiki_reset(*args, &block)
          mw = RSpec.configuration.send(PROXY_NAME)

          @live_media_wiki_url = mw.pool.fetch_url

          mw.config.values_at(:username, :password)
            .unshift(live_media_wiki_gateway(*args, &block))
        end

      end

    end

  end

end

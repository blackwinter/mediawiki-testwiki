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

require_relative 'rake_helper'

extend MediaWiki::TestWiki::RakeHelper

%w[main files setup docker].each { |task|
  load "media_wiki/test_wiki/tasks/#{task}.rake" }

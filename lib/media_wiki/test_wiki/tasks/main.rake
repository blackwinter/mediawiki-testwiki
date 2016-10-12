desc 'Build MediaWiki image'
task build: 'docker:build'

desc 'Start MediaWiki server'
task start: 'docker:start'

desc 'Stop MediaWiki server'
task stop: 'docker:stop'

desc 'Restart MediaWiki server'
task restart: 'docker:restart'

desc 'Shutdown MediaWiki server'
task shut: 'docker:clean'

%w[clean clobber].each { |task| task(task =>
  %w[setup docker].map { |namespace| "#{namespace}:#{task}" }) }

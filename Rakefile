# Official gems.
require 'colorize'
require 'rspec/core/rake_task'

# Git repo gems.
require 'bundler/setup'
require 'terramodtest'

namespace :static do
  task :style do
    style_tf
  end
  task :lint do
    lint_tf
  end
  task :format do
    format_tf
  end
end

namespace :integration do
  task :ensure do
    success = system ("dep ensure")
    if not success 
      raise "ERROR: Dep ensure failed!\n".red
    end
  end
  task :test do
    success = system ("go test -v ./test/ -timeout 20m -args azureuser ~/.ssh/id_rsa")
    if not success 
      raise "ERROR: Go test failed!\n".red
    end
  end
end

task :prereqs => []

task :validate => [ 'static:style', 'static:lint' ]

task :format => [ 'static:format' ]

task :build => [ 'prereqs', 'validate' ]

task :unit => []

task :e2e => [ 'integration:ensure', 'integration:test' ]

task :default => [ 'build' ]

task :full => [ 'build', 'unit', 'e2e' ]

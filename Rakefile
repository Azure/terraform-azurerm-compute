# Official gems.
require 'colorize'
require 'rspec/core/rake_task'

# Git repo gems.
require 'bundler/setup'
require 'terramodtest'

namespace :presteps do
  task :clean_up do
    clean_up_kitchen
    clean_up_terraform
  end
end

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
  task :converge do
    kitchen_converge
  end
  task :verify do
    kitchen_verify
  end
  task :test do
    kitchen_test
  end
  task :destroy do
    kitchen_destroy
  end
end

task :prereqs => [ 'presteps:clean_up' ]

task :validate => [ 'static:style', 'static:lint' ]

task :format => [ 'static:format' ]

task :build => [ 'prereqs', 'validate' ]

task :unit => []

task :e2e => [ 'integration:test' ]

task :default => [ 'build' ]

task :full => [ 'build', 'unit', 'e2e']

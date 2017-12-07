# Normal gems.
require 'colorize'
require 'rspec/core/rake_task'

# Git repo.
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
    exit_code = `kitchen converge`
    if exit_code != 0
      raise "ERROR: Test kitchen converge failed! #{exit_code}\n"
    end
  end
  task :verify do
    exit_code = `kitchen verify`
    if exit_code != 0
      raise "ERROR: Test kitchen verify failed! #{exit_code}\n"
    end
  end
  task :test do
    exit_code = `kitchen test`
    if exit_code != 0
      raise "ERROR: Test kitchen test failed! #{exit_code}\n"
    end
  end
  task :destroy do
    exit_code = `kitchen destroy`
    if exit_code != 0
      raise "ERROR: Test kitchen destroy failed! #{exit_code}\n"
    end
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

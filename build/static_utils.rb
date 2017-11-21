require 'colorize'
require 'fileutils'

def clean_up_kitchen
  if File.exists? '.kitchen'
    print "INFO: Cleaning up the .kitchen folder...\n"
    FileUtils.rm_rf('.kitchen')
  end
end

def lint_tf
  # Do the linting on current working folder.
  print "INFO: Linting Terraform configurations...\n".yellow  
  message = `terraform validate -check-variables=false 2>&1`

  # Check the linting message.
  if not message.empty?
    raise "ERROR: Linting terraform configurations failed!\n#{message}\n".red
  else
    print "INFO: Done!\n".green
  end
end

def style_tf
  # Do the style checking on current working folder.
  print "INFO: Style checking...\n".yellow  
  message = `terraform fmt -check=true 2>&1`

  # Check the styling message.
  if not message.empty?
    raise "ERROR: Styling terraform configurations failed!\n#{message}\n".red
  else
    print "INFO: Done!\n".green
  end
end

def format_tf
  # Apply the canonical format and style on current working folder.
  print "INFO: Formatting terraform configurations...\n".yellow  
  message = `terraform fmt -diff=true 2>&1`

  # Check the styling message.
  if not message.empty?
    raise "ERROR: Formatting terraform configurations failed!\n#{message}\n".red
  else
    print "INFO: Done!\n".green
  end
end
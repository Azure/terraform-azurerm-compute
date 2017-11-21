require 'fileutils'

def clean_up_kitchen
  if File.exists? '.kitchen'
    print "INFO: Cleaning up the .kitchen folder...\n"
    FileUtils.rm_rf('.kitchen')
  end
end

def clean_up_terraform
  if File.exists? '.terraform'
    print "INFO: Cleaning up the .terraform folder...\n"
    FileUtils.rm_rf('.terraform')
  end
end
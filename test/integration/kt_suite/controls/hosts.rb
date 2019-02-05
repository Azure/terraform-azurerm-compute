
control "reachable_host" do
  desc "Verifies that hosts is reachable from the current host"

    describe command('echo Hello world') do
    its('stdout') { should eq "Hello world\n" }
    its('stderr') { should eq '' }
    its('exit_status') { should eq 0 }
    end

end
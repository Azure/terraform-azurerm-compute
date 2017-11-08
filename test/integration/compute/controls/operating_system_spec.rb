# More info please refer to: https://www.inspec.io/docs/
# Define unique test case suite.
control 'operating_system' do
  # Define how critical this control is.
  impact 1.0
  # The actual test case.
  describe command('lsb_release -a') do
    its('stdout') { should match (/Ubuntu/) }
  end
end

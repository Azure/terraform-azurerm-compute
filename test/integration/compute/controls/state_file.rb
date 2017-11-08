terraform_state = attribute "terraform_state", {}

control "state_file" do
  describe "the Terraform state file" do
    subject do json(terraform_state).terraform_version end

    it "is accessible" do is_expected.to match /\d+\.\d+\.\d+/ end
  end
end

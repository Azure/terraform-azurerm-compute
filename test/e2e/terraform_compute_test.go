package e2e

import (
	"os"
	"testing"

	test_helper "github.com/Azure/terraform-module-test-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

const ipRegex = `^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$`

func TestExamplesComplete(t *testing.T) {
	vars := make(map[string]interface{})
	managedIdentityId := os.Getenv("MSI_ID")
	if managedIdentityId != "" {
		_ = os.Setenv("TF_VAR_managed_identity_principal_id", managedIdentityId)
	}
	test_helper.RunE2ETest(t, "../../", "examples/complete", terraform.Options{
		Upgrade: true,
		Vars:    vars,
	}, func(t *testing.T, output test_helper.TerraformOutput) {
		assertVmIpAddresses(t, "debian_ip_address", output)
		assertVmIpAddresses(t, "ubuntu_ip_address", output)
		assertVmIpAddresses(t, "windows_ip_address", output)
	})
}

func assertVmIpAddresses(t *testing.T, outputName string, output test_helper.TerraformOutput) {
	o, ok := output[outputName]
	assert.True(t, ok)
	addresses, ok := o.([]interface{})
	assert.True(t, ok)
	assert.Equal(t, 1, len(addresses))
	assert.Regexp(t, ipRegex, addresses[0].(string))
}

package upgrade

import (
	"testing"

	test_helper "github.com/Azure/terraform-module-test-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExampleUpgrade_complete(t *testing.T) {
	currentRoot, err := test_helper.GetCurrentModuleRootPath()
	if err != nil {
		t.FailNow()
	}
	currentMajorVersion, err := test_helper.GetCurrentMajorVersionFromEnv()
	if err != nil {
		t.FailNow()
	}
	test_helper.ModuleUpgradeTest(t, "Azure", "terraform-azurerm-compute", "examples/complete", currentRoot, terraform.Options{
		Upgrade: true,
	}, currentMajorVersion)
}

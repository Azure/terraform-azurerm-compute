package unit

import (
	"fmt"
	"strconv"
	"strings"
	"testing"

	test_helper "github.com/Azure/terraform-module-test-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func Test_ZeroInstancesShouldGenerateEmptyExtenions(t *testing.T) {
	vars := map[string]interface{}{
		"nb_instances": 0,
	}
	test_helper.RunE2ETest(t, "../../", "unit-fixture", terraform.Options{
		Upgrade: true,
		Vars:    vars,
	}, func(t *testing.T, output test_helper.TerraformOutput) {
		extensions, ok := output["vm_extensions"].(map[string]interface{})
		require.True(t, ok)
		require.Empty(t, extensions)
	})
}

func Test_EmptyExtensionsShouldGenerateEmptyExtenions(t *testing.T) {
	vars := map[string]interface{}{
		"nb_instances":  1,
		"vm_extensions": []interface{}{},
	}
	test_helper.RunE2ETest(t, "../../", "unit-fixture", terraform.Options{
		Upgrade: true,
		Vars:    vars,
	}, func(t *testing.T, output test_helper.TerraformOutput) {
		extensions, ok := output["vm_extensions"].(map[string]interface{})
		require.True(t, ok)
		require.Empty(t, extensions)
	})
}

func Test_OneInstances(t *testing.T) {
	vars := map[string]interface{}{
		"nb_instances": 1,
	}
	test_helper.RunE2ETest(t, "../../", "unit-fixture", terraform.Options{
		Upgrade: true,
		Vars:    vars,
	}, func(t *testing.T, output test_helper.TerraformOutput) {
		extensions, ok := output["vm_extensions"].(map[string]interface{})
		require.True(t, ok)
		require.Equal(t, 2, len(extensions))
		require.Contains(t, extensions, "hostname-0")
		require.Contains(t, extensions, "AzureMonitorLinuxAgent-0")
		for _, v := range extensions {
			m := v.(map[string]interface{})
			require.Zero(t, m["index"])
			require.Contains(t, m, "value")
		}
	})
}

func Test_TwoInstances(t *testing.T) {
	vars := map[string]interface{}{
		"nb_instances": 2,
	}
	test_helper.RunE2ETest(t, "../../", "unit-fixture", terraform.Options{
		Upgrade: true,
		Vars:    vars,
	}, func(t *testing.T, output test_helper.TerraformOutput) {
		extensions, ok := output["vm_extensions"].(map[string]interface{})
		require.True(t, ok)
		require.Equal(t, 4, len(extensions))
		require.Contains(t, extensions, "hostname-0")
		require.Contains(t, extensions, "AzureMonitorLinuxAgent-0")
		require.Contains(t, extensions, "hostname-1")
		require.Contains(t, extensions, "AzureMonitorLinuxAgent-1")
		for k, v := range extensions {
			index, err := strconv.ParseFloat(strings.Split(k, "-")[1], 64)
			require.Nil(t, err)
			m := v.(map[string]interface{})
			require.Equal(t, m["index"].(float64), index)
		}
	})
}

func Test_ExtensionVmIdMap(t *testing.T) {
	isWindowsImages := []bool{
		false,
		true,
	}
	for _, w := range isWindowsImages {
		t.Run(strconv.FormatBool(w), func(t *testing.T) {
			vars := map[string]interface{}{
				"is_windows_image": w,
				"nb_instances":     2,
			}
			test_helper.RunE2ETest(t, "../../", "unit-fixture", terraform.Options{
				Upgrade: true,
				Vars:    vars,
			}, func(t *testing.T, output test_helper.TerraformOutput) {
				extensions, ok := output["generated_extensions"].(map[string]interface{})
				require.True(t, ok)
				require.Equal(t, 4, len(extensions))
				for k, e := range extensions {
					m := e.(map[string]interface{})
					output := m["outputs"].(map[string]interface{})
					vmId := output["virtual_machine_id"].(string)
					prefix := "linux-%s"
					if w {
						prefix = "windows-%s"
					}
					index := strings.Split(k, "-")[1]
					require.Equal(t, fmt.Sprintf(prefix, index), vmId)
				}
			})
		})
	}
}

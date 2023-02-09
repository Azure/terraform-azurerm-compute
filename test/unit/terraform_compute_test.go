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
		isWindows := w
		t.Run(strconv.FormatBool(isWindows), func(t *testing.T) {
			vars := map[string]interface{}{
				"is_windows_image": isWindows,
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
					if isWindows {
						prefix = "windows-%s"
					}
					index := strings.Split(k, "-")[1]
					require.Equal(t, fmt.Sprintf(prefix, index), vmId)
				}
			})
		})
	}
}

func Test_DefaultOrTrueNestedDataDisksShouldNotCreateAttachmentResource(t *testing.T) {
	test_helper.RunE2ETest(t, "../../", "unit-fixture", terraform.Options{
		Vars: map[string]interface{}{
			"nested_data_disks": true,
			"nb_instances":      2,
			"nb_data_disk":      2,
			"extra_disks": `[
	{ 
		name = "lun0"
		size = 30
	}
]`,
		},
	}, func(t *testing.T, output test_helper.TerraformOutput) {
		dataList := output["data_disk_list"].([]any)
		require.NotEmpty(t, dataList)
		nestedDataDiskList := output["nested_data_disk_list"].([]any)
		require.Equal(t, 2, len(nestedDataDiskList))
		extraDataList := output["extra_data_disk_list"].([]any)
		require.NotEmpty(t, extraDataList)
		nestedExtraDataList := output["nested_extra_data_disk_list"].([]any)
		require.NotEmpty(t, nestedExtraDataList)
		dataDisks := output["data_disk_map"].(map[string]any)
		require.Empty(t, dataDisks)
		extraDataDisks := output["extra_disk_map"].(map[string]any)
		require.Empty(t, extraDataDisks)
	})
}

func Test_FalseNestedDataDisksShouldCreateAttachmentResource(t *testing.T) {
	test_helper.RunE2ETest(t, "../../", "unit-fixture", terraform.Options{
		Vars: map[string]interface{}{
			"nested_data_disks": false,
			"nb_instances":      2,
			"nb_data_disk":      2,
			"extra_disks": `[
	{ 
		name = "lun0"
		size = 30
	}
]`,
		},
	}, func(t *testing.T, output test_helper.TerraformOutput) {
		dataList := output["data_disk_list"].([]any)
		require.NotEmpty(t, dataList)
		nestedDataDiskList := output["nested_data_disk_list"].([]any)
		require.Empty(t, nestedDataDiskList)
		extraDataList := output["extra_data_disk_list"].([]any)
		require.NotEmpty(t, extraDataList)
		nestedExtraDataList := output["nested_extra_data_disk_list"].([]any)
		require.Empty(t, nestedExtraDataList)
		dataDisks := output["data_disk_map"].(map[string]any)
		require.Equal(t, 4, len(dataDisks))
		extraDataDisks := output["extra_disk_map"].(map[string]any)
		require.Equal(t, 2, len(extraDataDisks))
	})
}

func Test_DataDisksAttachmentShouldMatchOs(t *testing.T) {
	isWindows := []bool{
		false, true,
	}
	for _, w := range isWindows {
		isLinux := !w
		t.Run(strconv.FormatBool(isLinux), func(t *testing.T) {
			test_helper.RunE2ETest(t, "../../", "unit-fixture", terraform.Options{
				Vars: map[string]interface{}{
					"is_windows_image":  !isLinux,
					"nested_data_disks": false,
					"nb_instances":      2,
					"nb_data_disk":      2,
					"extra_disks": `[
	{ 
		name = "lun0"
		size = 30
	}
]`,
				},
			}, func(t *testing.T, output test_helper.TerraformOutput) {
				dataDiskMapLinux := output["data_disk_map_linux"].(map[string]any)
				dataDiskMapWindows := output["data_disk_map_windows"].(map[string]any)
				extraDiskMapLinux := output["extra_disk_map_linux"].(map[string]any)
				extraDiskMapWindows := output["extra_disk_map_windows"].(map[string]any)
				if isLinux {
					require.Empty(t, dataDiskMapWindows)
					require.Empty(t, extraDiskMapWindows)
					require.NotEmpty(t, dataDiskMapLinux)
					require.NotEmpty(t, extraDiskMapLinux)
				} else {
					require.NotEmpty(t, dataDiskMapWindows)
					require.NotEmpty(t, extraDiskMapWindows)
					require.Empty(t, dataDiskMapLinux)
					require.Empty(t, extraDiskMapLinux)
				}
			})
		})
	}
}

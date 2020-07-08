# Apply Deny PublicIP Policies on a Subscription

This module will apply a set of policies to deny the use of public IP on resources deployed in a subscription to comply with PBMM Guardrails.

Reference the module to a specific version (recommended):
```hcl
module Project-Deny-PublicIP-Policy {
  source                  = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-deny-publicip_policy_set?ref=v0.1.1"
  env                     = var.env
  userDefinedString       = local.prefix
  log_analytics_workspace = local.Project-law
}

```

## Inputs 

| Name                    | Type   | Default | Description                                                                                                                          |
| ----------------------- | ------ | ------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| log_analytics_workspace | object | None    | (Required) The log analytics workspace object where to send the diagnostics logs. Changing this forces a new resource to be created. |
| env                     | string | None    | (Required) env name                                                                                                                  |
| userDefinedString       | string | None    | (Required) userDefinedString to be Used.                                                                                             |
| management_group_name   | string | None    | (Optional) The name of the Management Group where this policy should be defined. Changing this forces a new resource to be created.  |
| deploy                  | bool   | true    | (Optional) Should the module be deployed                                                                                             |

## Parameters

## Outputs
| Name                  | Type   | Description                                    |
| --------------------- | ------ | ---------------------------------------------- |
| policy_set_definition | object | Returns the full policy_set_definition object. |
| policy_assignment     | object | Returns the full policy_assignment object      |

data azurerm_subscription primary {}

locals {
  policy_set_name = substr("${var.env}-${var.userDefinedString} deny PublicIP policy set", 0, 64)
  subscriptionID  = data.azurerm_subscription.primary.subscription_id
  policies_json   = var.deploy ? templatefile("${path.module}/policies/all-PublicIP-Policies.json", { subscriptionID = local.subscriptionID }) : "[]"
  policies = {
    for policy in jsondecode(local.policies_json) :
    policy.Name => {
      name        = policy.Name
      description = try(policy.Properties.description, "")
      policyRule  = policy.Properties.policyRule
    }
  }
  policy_assignment = [
    for policy in jsondecode(local.policies_json) :
    {
      "parameters" : {},
      "policyDefinitionId" : "/subscriptions/${local.subscriptionID}/providers/Microsoft.Authorization/policyDefinitions/${policy.Name}"
    }
  ]
}

resource "azurerm_policy_definition" "policy_definition" {
  for_each = local.policies
  # No need for count since we handle the the local.policies content at the local file read time
  name         = each.value.name
  policy_type  = "Custom"
  mode         = "All"
  display_name = each.value.name
  description  = each.value.description
  policy_rule = jsonencode(each.value.policyRule)
}

resource "azurerm_policy_set_definition" "policy_set_definition" {
  depends_on         = [azurerm_policy_definition.policy_definition]
  count              = var.deploy ? 1 : 0
  name               = local.policy_set_name
  policy_type        = "Custom"
  display_name       = local.policy_set_name
  description        = "This initiative deny the deployment of resources with PublicIP."
  policy_definitions = jsonencode(local.policy_assignment)
}

resource "azurerm_policy_assignment" "policy_assignment" {
  count                = var.deploy ? 1 : 0
  name                 = local.policy_set_name
  location             = var.log_analytics_workspace.location
  scope                = data.azurerm_subscription.primary.id
  policy_definition_id = azurerm_policy_set_definition.policy_set_definition[0].id
  display_name         = local.policy_set_name
  description          = "Apply Deny PublicIP policy for Azure for PBMM Guardrails compliance"
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_resource_group" "rg" {
    name = "logic-rg"
    location = "eastus"
}

resource "azurerm_logic_app_workflow" "workflow" {
    name = "logic-workflow"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    enabled = true
    workflow_schema = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
}

resource "azurerm_logic_app_trigger_custom" "trigger" {
  name = "logic-trigger"
  logic_app_id = azurerm_logic_app_workflow.workflow.id

  body = <<BODY
{
  "when_new_mail_arrives": {
    "input": {
        "email provider": "Office 365 Outlook"
        "folder": "inbox"
        "importance": "any"
        "domain":"xor.com"
        "only with attachment": "no"
        "include attachments": "yes"
    },
    "queries":{
        "interval": 15
        "frequency": "minute"
    },
    "conditions":[ {
        "epression":"@contains(triggerBody()?['domain'],not(domain) )
    } ]
    "type": "ApiConnection"
  }
}
BODY
}

resource "azurerm_logic_app_action_custom" "action" {
  name         = "logic-action"
  logic_app_id = azurerm_logic_app_workflow.workflow.id

  body = <<BODY
{
    "description": "To send an email alert if other domain emails are received.",
    "inputs": {
        "body": {
                "to": ["management@xor.com", "development_team@xor.com", "it-support@xor.com"]
                "subject": "Important! Mail received from different domain."
                "body": ["importance", "from", "path", "body"]
        },
        "method":"post"
    },
    "runAfter": {"logic-trigger": "active"},
    "type": "ApiConnection"
}
BODY
}


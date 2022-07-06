#Azure Service Bus - Queue 
resource "azurerm_resource_group" "rg" {
    name = "queue_rg"
    location = "eastus"
}

resource "azurerm_servicebus_namespace" "namespace" {
    name = "queue_ns"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    sku = "standard"
    local_auth_enabled = true
    zone_redundant = true
    
}

resource "azurerm_servicebus_namespace_authorization_rule" "ns-rule" {
    name = "queue_ns_rule"
    namespace_id = azurerm_servicebus_namespace.namespace.id
    send = true
    listen = true
    manage = true
}

 resource "azurerm_servicebus_queue" "queue" {
    name = "asb_queue"
    namespace_id = azurerm_servicebus_namespace.namespace.id
    id = azurerm_servicebus_namespace.namespace.default_primary_connection_string
    max_size_in_megabytes = 1024
    requires_duplicate_detection = true
}

 resource "azurerm_servicebus_queue_authorization_rule" "queue_rule" {
    name = "asb_queue_rule"
    queue_id = azurerm_servicebus_queue.queue.id
    send = true
    listen = true
    manage = true
}


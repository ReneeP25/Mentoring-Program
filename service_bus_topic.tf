resource "azurerm_resource_group" "r-g" {
    name = "topic_rg"
    location = "centralus"
}

resource "azurerm_servicebus_namespace" "namespace2" {
    name = "topic_ns"
    resource_group_name = azurerm_resource_group.r-g.name
    location = azurerm_resource_group.r-g.location
    local_auth_enabled = true
    sku = "standard"
    zone_redundant = true
}

resource "azurerm_servicebus_namespace_authorization_rule" "ns-rule" {
    name = "topic-ns-rule"
    namespace_id = azurerm_servicebus_namespace.namespace2.id
    send = true
    listen = true
    manage = true  
}

resource "azurerm_servicebus_topic" "topic" {
    name = "asb-topic"
    namespace_id = azurerm_servicebus_namespace.namespace2.id
    id = azurerm_servicebus_namespace.namespace2.default_primary_connection_string
    status = "active"
    max_size_in_megabytes = 1024
    requires_duplicate_detection = true
}

resource "azurerm_servicebus_topic_authorization_rule" "topic-rule" {
    name = "topic-rule1"
    topic_id = azurerm_servicebus_topic.topic.id
   
    send = true
    listen = true
    manage = true  
}

resource "azurerm_servicebus_subscription" "subscription1" {
    name = "topic-subps1"
    topic_id = azurerm_servicebus_topic.topic.id
    max_delivery_count = 3
    auto_delete_on_idle = 40
    status = "active"
}

resource "azurerm_servicebus_subscription" "subscription2" {
    name = "topic-subps2"
    topic_id = azurerm_servicebus_topic.topic.id
    max_delivery_count = 3
    auto_delete_on_idle = 20
    status = "active"
}

resource "azurerm_servicebus_subscription" "subscription3" {
    name = "topic-subps3"
    topic_id = azurerm_servicebus_topic.topic.id
    max_delivery_count = 3
    auto_delete_on_idle = 30
    status = "active"
}

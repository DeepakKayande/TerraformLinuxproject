resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "autoscale"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Link to the Windows VMSS
  target_resource_id  = azurerm_orchestrated_virtual_machine_scale_set.vmss_terraform_tutorial.id
  enabled             = true

  profile {
    name = "autoscale"
    capacity {
      default = 3      # Start with 3 instances
      minimum = 1      # Never go below 1 instance
      maximum = 10     # Cap at 10 instances
    }

    # ----------- Scale OUT (increase) when CPU > 80% for 2 mins ----------
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_orchestrated_virtual_machine_scale_set.vmss_terraform_tutorial.id
        time_grain         = "PT1M"     # Metric collected every 1 minute
        statistic          = "Average"
        time_window        = "PT2M"     # Check over a 2-minute window
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 80
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"      # Add one VM
        cooldown  = "PT5M"   # Wait 5 minutes before evaluating again
      }
    }

    # ----------- Scale IN (decrease) when CPU < 10% for 2 mins ----------
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_orchestrated_virtual_machine_scale_set.vmss_terraform_tutorial.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT2M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 10
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"      # Remove one VM
        cooldown  = "PT5M"   # Wait 5 minutes before scaling again
      }
    }
  }
}

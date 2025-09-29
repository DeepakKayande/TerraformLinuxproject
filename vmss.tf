resource "azurerm_orchestrated_virtual_machine_scale_set" "vmss_terraform_tutorial" {
  name                        = "vmss-terraform"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  sku_name                    = "Standard_D2s_v4"      # VM size
  instances                   = 3
  platform_fault_domain_count = 1                       # Required for zonal deployment
  zones                       = ["1"]

  # ---------------------- Windows OS Profile ----------------------
  os_profile {
    windows_configuration {
      enable_automatic_updates = true                   # Windows Update enabled
      provision_vm_agent       = true                   # Azure VM agent for extensions
      admin_username           = "azureadmin"           # Windows local admin user
      admin_password           = var.admin_password     # Secure password (define in variables.tf)
      computer_name_prefix     = "winvm"                # Hostname prefix for instances
    }
  }

  # ---------------------- Windows Image ---------------------------
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"                       # Can be 2022-Datacenter if required
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }

  # ---------------------- Networking ------------------------------
  network_interface {
    name                          = "nic"
    primary                       = true
    enable_accelerated_networking = false

    ip_configuration {
      name                                   = "ipconfig"
      primary                                = true
      subnet_id                              = azurerm_subnet.subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bepool.id]
    }
  }

  # ---------------------- Diagnostics ------------------------------
  boot_diagnostics {
    storage_account_uri = ""
  }

  # ---------------------- Lifecycle ------------------------------
  lifecycle {
    ignore_changes = [
      instances
    ]
  }
}

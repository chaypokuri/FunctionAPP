resource "azurerm_linux_function_app" "linux_function_app" {
  ## REQUIRED CONFIGURATIONS ##
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  service_plan_id               = var.service_plan_id
  storage_account_name          = var.backend_storage_account_name
  storage_uses_managed_identity = local.storage_uses_managed_identity
  virtual_network_subnet_id     = var.subnet_id
  tags                          = var.tags

  site_config {
    always_on                              = var.site_config.always_on
    api_definition_url                     = var.site_config.api_definition_url
    api_management_api_id                  = var.site_config.api_management_api_id
    app_scale_limit                        = var.site_config.app_scale_limit
    application_insights_connection_string = var.site_config.application_insights_connection_string
    application_insights_key               = var.site_config.application_insights_key
    elastic_instance_minimum               = var.site_config.elastic_instance_minimum
    minimum_tls_version                    = local.site_config.minimum_tls_version
    scm_minimum_tls_version                = local.site_config.minimum_tls_version

    dynamic "application_stack" {
      for_each = var.application_stack != null ? [var.application_stack] : []

      content {
        dotnet_version              = application_stack.value.dotnet_version
        use_dotnet_isolated_runtime = application_stack.value.use_dotnet_isolated_runtime
        java_version                = application_stack.value.java_version
        node_version                = application_stack.value.node_version
        python_version              = application_stack.value.python_version
        powershell_core_version     = application_stack.value.powershell_core_version
        use_custom_runtime          = application_stack.value.use_custom_runtime

        dynamic "docker" {
          for_each = application_stack.value.docker_images != null ? [application_stack.value.docker_images] : []

          content {
            registry_url      = docker.value.registry_url
            image_name        = docker.value.image_name
            image_tag         = docker.value.image_tag
            registry_username = docker.value.registry_username
            registry_password = docker.value.registry_password
          }
        }
      }
    }

    dynamic "cors" {
      for_each = var.site_config.cors != null ? [var.site_config.cors] : []

      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }
  }

  backup {
    name                = local.backup_name
    storage_account_url = var.backup.storage_account_url
    enabled             = local.backup_enabled

    schedule {
      frequency_interval = var.backup.schedule.frequency_interval
      frequency_unit     = var.backup.schedule.frequency_unit
    }
  }

  ## OPTIONAL CONFIGURATIONS ##
  app_settings                       = var.app_settings
  builtin_logging_enabled            = var.builtin_logging_enabled
  client_certificate_enabled         = try(var.client_certificates.client_certificate_enabled, null)
  client_certificate_mode            = try(var.client_certificates.client_certificate_mode, null)
  client_certificate_exclusion_paths = try(var.client_certificates.client_certificate_exclusion_paths, null)
  https_only                         = local.https_only
  public_network_access_enabled      = local.public_network_access_enabled

  dynamic "auth_settings" {
    for_each = var.auth_settings != null ? [var.auth_settings] : []

    content {
      enabled                       = auth_settings.value.enabled
      default_provider              = local.ad_default_provider
      runtime_version               = auth_settings.value.runtime_version
      unauthenticated_client_action = local.unauthenticated_client_action

      active_directory {
        client_id                  = auth_settings.value.active_directory.client_id
        client_secret_setting_name = auth_settings.value.active_directory.client_secret_setting_name
      }
    }
  }

  dynamic "auth_settings_v2" {
    for_each = var.auth_settings_v2 != null ? [var.auth_settings_v2] : []

    content {
      auth_enabled           = auth_settings_v2.value.auth_enabled
      runtime_version        = auth_settings_v2.value.runtime_version
      config_file_path       = auth_settings_v2.value.config_file_path
      require_authentication = auth_settings_v2.value.require_authentication
      unauthenticated_action = local.unauthenticated_client_action
      default_provider       = lower(local.ad_default_provider)

      login {
        logout_endpoint     = auth_settings_v2.value.login.logout_endpoint
        token_store_enabled = auth_settings_v2.value.login.token_store_enabled
        token_store_path    = auth_settings_v2.value.login.token_store_path
      }

      dynamic "active_directory_v2" {
        for_each = auth_settings_v2.value.active_directory_v2 != null ? [auth_settings_v2.value.active_directory_v2] : []

        content {
          client_id                  = active_directory_v2.value.client_id
          tenant_auth_endpoint       = active_directory_v2.value.tenant_auth_endpoint
          client_secret_setting_name = active_directory_v2.value.client_secret_setting_name
        }
      }
    }
  }

  dynamic "connection_string" {
    for_each = var.connection_strings != null ? [var.connection_strings] : []

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "sticky_settings" {
    for_each = var.sticky_settings != null ? [var.sticky_settings] : []

    content {
      app_setting_names       = sticky_settings.value.app_setting_names
      connection_string_names = sticky_settings.value.connection_string_names
    }
  }

  lifecycle {
    ignore_changes = [app_settings, sticky_settings]
  }
}

resource "sumologic_role" "tf_test_role_01" {
  name        = "tf_test_role_01"
  description = "Testing resource sumologic_role"
  capabilities = [
    "viewAlerts",
    "viewMonitorsV2",
    "manageMonitorsV2"
  ]
}
resource "sumologic_role" "tf_test_role_02" {
  name        = "tf_test_role_02"
  description = "Testing resource sumologic_role"
  capabilities = [
    "viewAlerts",
    "viewMonitorsV2",
    "manageMonitorsV2"
  ]
}
resource "sumologic_monitor" "tf_logs_monitor_1" {
  name         = "Terraform Logs Monitor"
  description  = "tf logs monitor"
  type         = "MonitorsLibraryMonitor"
  is_disabled  = false
  content_type = "Monitor"
  monitor_type = "Logs"
  evaluation_delay = "5m"
  tags = {
    "team" = "monitoring"
    "application" = "sumologic"
  }

  queries {
    row_id = "A"
    query  = "_sourceCategory=event-action info"
  }

  trigger_conditions {
    logs_static_condition {
      critical {
        time_range = "15m"
        alert {
          threshold      = 40.0
          threshold_type = "GreaterThan"
        }
        resolution {
          threshold      = 40.0
          threshold_type = "LessThanOrEqual"
        }
      }
    }
  }

  notifications {
    notification {
      connection_type = "Email"
      recipients = [
        "abc@example.com",
      ]
      subject      = "Monitor Alert: {{TriggerType}} on {{Name}}"
      time_zone    = "PST"
      message_body = "Triggered {{TriggerType}} Alert on {{Name}}: {{QueryURL}}"
    }
    run_for_trigger_types = ["Critical", "ResolvedCritical"]
  }
  notifications {
    notification {
      connection_type = "Webhook"
      connection_id   = "0000000000ABC123"
    }
    run_for_trigger_types = ["Critical", "ResolvedCritical"]
  }
  playbook = "{{Name}} should be fixed in 24 hours when {{TriggerType}} is triggered."
  alert_name = "Alert {{ResultJson.my_field}} from {{Name}}"
  notification_group_fields = ["_sourceHost"]
  obj_permission {
    subject_type = "role"
    subject_id = sumologic_role.tf_test_role_01.id
    permissions = ["Read","Update"]
  }
  obj_permission {
    subject_type = "role"
    subject_id = sumologic_role.tf_test_role_02.id
    permissions = ["Read"]
  }
}

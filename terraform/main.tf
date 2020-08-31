terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 2.6.0"
    }
  }
}

##
# New Relic Terraform Provider configuration
#
#
##
provider "newrelic" {
  api_key    = var.api_key
  account_id = var.account_id
}

##
# Hello App
#
# This data source fetches the data for your "Hello App" which is used within the resources below
# to associate certain resources with the application.
#
# https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/data-sources/entity
##
data "newrelic_entity" "hello_app" {
  name   = var.app_name
  domain = "APM"
  type   = "APPLICATION"
}

##
# Dashboard for Hello App
#
# https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/dashboard
##
resource "newrelic_dashboard" "hello_app_dashboard" {
  title             = var.dashboard_name != "" ? var.dashboard_name : var.app_name
  icon              = "line-chart"
  grid_column_count = 12
  visibility        = "all"
  editable          = "editable_by_all"

  widget {
    title         = ""
    visualization = "markdown"
    source        = "# You've just created your dashboard\n\nAn explanation here of what to do next.\n\nMaybe put a [link here](https://newrelic.com) to point them at a relevant page."
    width         = 4
    height        = 6
    row           = 1
    column        = 1
  }

  widget {
    title         = "Slowest endpoints (95th percentile)"
    visualization = "facet_bar_chart"
    nrql          = "SELECT average(duration) FROM Transaction FACET name WHERE appName = '${var.app_name}'"
    width         = 4
    height        = 3
    row           = 1
    column        = 5
  }

  widget {
    title         = "HTTP Responses"
    visualization = "facet_bar_chart"
    nrql          = "SELECT count(*) FROM Transaction TIMESERIES FACET httpResponseCode where appName = '${var.app_name}'"
    width         = 4
    height        = 3
    row           = 1
    column        = 9
  }

  widget {
    title         = "Request breakdown by user agent"
    visualization = "facet_pie_chart"
    nrql          = "SELECT count(*) FROM Transaction FACET request.headers.userAgent LIMIT MAX"
    width         = 4
    height        = 3
    row           = 4
    column        = 5
  }

  widget {
    title         = "Memory used"
    visualization = "faceted_area_chart"
    nrql          = "SELECT average(memoryUsedPercent) as '% Used', average(memoryFreePercent) as '% Free' FROM SystemSample TIMESERIES WHERE apmApplicationNames = '|${var.app_name}|'"
    width         = 4
    height        = 3
    row           = 4
    column        = 9
  }
}

##
# Alert policy
#
# https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/alert_policy
##
resource "newrelic_alert_policy" "hello_app" {
  name = var.alert_policy_name
}

##
# Alert condition (apdex)
#
# https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/alert_condition
##
resource "newrelic_alert_condition" "hello_app_apdex" {
  policy_id       = newrelic_alert_policy.hello_app.id
  name            = "Apdex - ${var.app_name}"
  type            = "apm_app_metric"
  entities        = [data.newrelic_entity.hello_app.application_id]
  metric          = "apdex"
  runbook_url     = "https://www.example.com"
  condition_scope = "application"

  term {
    duration      = 5
    operator      = "below"
    priority      = "critical"
    threshold     = "0.75"
    time_function = "all"
  }
}

##
# Alert condition (high web response time)
#
# Define a critical alert threshold that will trigger after 5 minutes above 5 seconds per request.
#
# https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/alert_condition
##
resource "newrelic_alert_condition" "response_time_web" {
  policy_id       = newrelic_alert_policy.hello_app.id
  name            = "High Response Time (web) - ${var.app_name}"
  type            = "apm_app_metric"
  entities        = [data.newrelic_entity.hello_app.application_id]
  metric          = "response_time_web"
  condition_scope = "application"

  term {
    duration      = 5
    operator      = "above"
    priority      = "critical"
    threshold     = "5"
    time_function = "all"
  }
}

##
# Alert condition (low throughput)
#
# Defines a critical alert threshold that will trigger after 5 minutes below 1 request per minute.
#
# https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/alert_condition
##
resource "newrelic_alert_condition" "throughput_web" {
  policy_id       = newrelic_alert_policy.hello_app.id
  name            = "Low Throughput (web)"
  type            = "apm_app_metric"
  entities        = [data.newrelic_entity.hello_app.application_id]
  metric          = "throughput_web"
  condition_scope = "application"

  term {
    duration      = 5
    operator      = "below"
    priority      = "critical"
    threshold     = "1"
    time_function = "all"
  }
}

##
# Alert condition (high error percentage)
#
# Define a critical alert threshold that will trigger after 5 minutes above a 5% error rate.
#
# https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/alert_condition
##
resource "newrelic_alert_condition" "error_percentage" {
  policy_id       = newrelic_alert_policy.hello_app.id
  name            = "High Error Percentage"
  type            = "apm_app_metric"
  entities        = [data.newrelic_entity.hello_app.application_id]
  metric          = "error_percentage"
  runbook_url     = "https://www.example.com"
  condition_scope = "application"

  term {
    duration      = 5
    operator      = "above"
    priority      = "critical"
    threshold     = "5"
    time_function = "all"
  }
}

##
# NRQL alert condition (slow transactions)
#
# https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/nrql_alert_condition
##
resource "newrelic_nrql_alert_condition" "hello_app_slow_transactions" {
  account_id           = var.account_id
  policy_id            = newrelic_alert_policy.hello_app.id
  type                 = "static"
  name                 = "Slow Transactions - ${var.app_name}"
  description          = "Alert when transactions are taking too long."
  runbook_url          = "https://www.example.com"
  enabled              = true
  value_function       = "single_value"
  violation_time_limit = "one_hour"

  nrql {
    query             = "SELECT average(duration) FROM Transaction where appName = '${var.app_name}'"
    evaluation_offset = 3 # Recommended 3 per New Relic UI (this is the default under the hood)
  }

  critical {
    operator              = "above"
    threshold             = 5.5
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }

  warning {
    operator              = "above"
    threshold             = 3.5
    threshold_duration    = 600
    threshold_occurrences = "ALL"
  }
}

##
# Infrastructure alert condition (high CPU)
#
# Defines a critical alert threshold that will trigger after 5 minutes above 90% CPU utilization.
#
# https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/nrql_alert_condition
##
resource "newrelic_infra_alert_condition" "high_cpu" {
  policy_id   = newrelic_alert_policy.hello_app.id
  name        = "High CPU usage - ${var.app_name}"
  type        = "infra_metric"
  event       = "SystemSample"
  select      = "cpuPercent"
  comparison  = "above"
  runbook_url = "https://www.example.com"
  where       = "(`applicationId` = '${data.newrelic_entity.hello_app.application_id}')"

  critical {
    duration      = 5
    value         = 90
    time_function = "all"
  }
}

##
# Notification channel (email)
#
# https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/alert_channel
##
resource "newrelic_alert_channel" "email_notification_channel" {
  name = "Email Notification Channel - ${var.app_name}"
  type = "email"

  config {
    recipients              = "example@yourdomain.com"
    include_json_attachment = "1" # 0 or 1 (true or false)
  }
}

##
# Adds notification channel(s) to an alert policy.
#
# https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/alert_policy_channel
##
resource "newrelic_alert_policy_channel" "golden_signal_policy_pagerduty" {
  policy_id  = newrelic_alert_policy.hello_app.id
  channel_ids = [newrelic_alert_channel.email_notification_channel.id]
}

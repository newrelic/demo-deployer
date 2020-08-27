terraform {
  required_providers {
    newrelic = {
      source = "newrelic/newrelic"
      version = "2.6.0"
    }
  }
}

provider "newrelic" {
  api_key = var.api_key
  account_id = var.account_id
}

data "newrelic_entity" "hello_app" {
  name = var.app_name
  domain = "APM"
  type = "APPLICATION"
}

resource "newrelic_alert_policy" "foo" {
  name = var.alert_policy_name
}

resource "newrelic_alert_condition" "foo" {
  policy_id = newrelic_alert_policy.foo.id

  name        = "foo"
  type        = "apm_app_metric"
  entities    = [data.newrelic_entity.hello_app.application_id]
  metric      = "apdex"
  runbook_url = "https://www.example.com"

  term {
    duration      = 5
    operator      = "below"
    priority      = "critical"
    threshold     = "0.75"
    time_function = "all"
  }
}

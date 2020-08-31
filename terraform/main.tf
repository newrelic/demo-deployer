terraform {
  required_providers {
    newrelic = {
      source = "newrelic/newrelic"
      version = "~> 2.6.0"
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

resource "newrelic_dashboard" "hello_app_dashboard" {
  title = var.dashboard_name != "" ? var.dashboard_name : var.app_name
  icon = "line-chart"
  grid_column_count = 12
  visibility = "all"
  editable = "editable_by_all"

  widget {
    title = ""
    visualization = "markdown"
    source = "# You've just created your dashboard\n\nAn explanation here of what to do next.\n\nMaybe put a [link here](https://newrelic.com) to point them at a relevant page."
    width = 4
    height = 6
    row = 1
    column = 1
  }

  widget {
    title = "Slowest endpoints (95th percentile)"
    visualization = "facet_bar_chart"
    nrql = "SELECT average(duration) FROM Transaction FACET name WHERE appName = '${var.app_name}'"
    width = 4
    height = 3
    row = 1
    column = 5
  }

  widget {
    title = "HTTP Responses"
    visualization = "facet_bar_chart"
    nrql = "SELECT count(*) FROM Transaction TIMESERIES FACET httpResponseCode where appName = '${var.app_name}'"
    width = 4
    height = 3
    row = 1
    column = 9
  }

  widget {
    title = "Request breakdown by user agent"
    visualization = "facet_pie_chart"
    nrql = "SELECT count(*) FROM Transaction FACET request.headers.userAgent LIMIT MAX"
    width = 4
    height = 3
    row = 4
    column = 5
  }

  widget {
    title = "Memory used"
    visualization = "faceted_area_chart"
    nrql = "SELECT average(memoryUsedPercent) as '% Used', average(memoryFreePercent) as '% Free' FROM SystemSample TIMESERIES WHERE apmApplicationNames = '|${var.app_name}|'"
    width = 4
    height = 3
    row = 4
    column = 9
  }
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
  condition_scope = "application"

  term {
    duration      = 5
    operator      = "below"
    priority      = "critical"
    threshold     = "0.75"
    time_function = "all"
  }
}

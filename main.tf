terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "3.49.0" # Specify the desired version
    }
  }
}

resource "datadog_monitor" "tech4dev_ec2_monitor" {
  name               = "Name for monitor tech4dev ec2"
  type               = "metric alert"
  message            = "Monitor triggered. Notify: @hipchat-channel"
  escalation_message = "Escalation message @pagerduty"

  query = "avg(last_1h):avg:aws.ec2.cpu{environment:development,host:tech4dev1} by {tech4dev1} > 5"

  monitor_thresholds {
    warning  = 3
    critical = 5
  }

  include_tags = true

  tags = ["env:development", "monitor:ec2_cpu"]
}


resource "datadog_dashboard" "aws_dashboard" {
  title       = "AWS Metrics Dashboard"
  description = "Dashboard for monitoring AWS metrics"
  layout_type = "ordered"

  widget {
    timeseries_definition {
      request {
        q = "avg:aws.ec2.cpuutilization{environment:development} by {tech4dev1}"
        display_type = "line"
        style {
          palette = "cool"
          line_type = "solid"
          line_width = "normal"
        }
      }
      title = "CPU Utilization"
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.ec2.mem.used{environment:development} by {tech4dev1}"
        display_type = "line"
        style {
          palette    = "orange"
          line_type  = "solid"
          line_width = "normal"
        }
      }
      title = "Memory Utilization"
    }
  }
}

terraform {
  required_providers {
    bindplane = {
      source = "observiq/bindplane-enterprise"
    }
  }
}

provider "bindplane" {
  # remote_url = "http://localhost:3001"
  # username = "admin"
  # password = "admin"

  remote_url = "http://35.223.214.196:3001"
  api_key = "e1e47c58-3610-42a8-b7f7-25830d6b2fd5"
  # username = "admin"
  # password = "admin"
}

resource "bindplane_source" "host" {
  rollout = true
  name = "my-host"
  type = "host"
  parameters_json = jsonencode(
    [
      {
        "name": "collection_interval",
        "value": 60
      },
      {
        "name": "enable_process",
        "value": true
      }
    ]
  )
}

resource "bindplane_source" "journald" {
  rollout = true
  name = "my-journald"
  type = "journald"
}

resource "bindplane_destination" "google" {
  rollout = true
  name = "my-google"
  type = "googlecloud"
}

resource "bindplane_destination" "logging" {
  rollout = true
  name = "logging"
  type = "custom"
  parameters_json = jsonencode(
    [
      {
        "name": "telemetry_types",
        "value": ["Metrics", "Logs", "Traces"]
      },
      {
        "name": "configuration",
        "value": "logging: # commedddntsss"
      }
    ]
  )
}

resource "bindplane_processor" "add_fields" {
  rollout = true
  name = "add-fields"
  type = "add_fields"
  parameters_json = jsonencode(
    [
      {
        "name": "enable_logs"
        "value": false
      },
      {
        "name": "log_resource_attributes",
        "value": {
          "key": "bgwaaadddfgw"
        }
      }
    ]
  )
}

resource "bindplane_processor" "batch" {
  rollout = true
  name = "batch"
  type = "batch"
  parameters_json = jsonencode(
    [
      {
        "name": "send_batch_size",
        "value": 200
      },
      {
        "name": "send_batch_max_size",
        "value": 400
      },
      {
        "name": "timeout",
        "value": "5s"
      }
    ]
  )
}

resource "bindplane_configuration" "configuration" {
  rollout = true
  name = "my-config"
  platform = "linux"
  labels = {
    environment = "production"
    managed-by  = "terraform"
  }

  source {
    name = bindplane_source.host.name
    processors = [
      bindplane_processor.add_fields.name
    ]
  }

  source {
    name = bindplane_source.journald.name
    processors = [
      bindplane_processor.add_fields.name
    ]
  }

  destination {
    name = bindplane_destination.google.name
    processors = [
      bindplane_processor.batch.name
    ]
  }

  destination {
    name = bindplane_destination.logging.name
    processors = [
      bindplane_processor.batch.name
    ]
  }
}

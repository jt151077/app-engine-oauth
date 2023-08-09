/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


data "archive_file" "source" {
  type        = "zip"
  source_dir  = "./app"
  output_path = "/tmp/app.zip"
}

resource "google_storage_bucket" "function_bucket" {
  depends_on = [
    google_project_service.gcp_services
  ]

  name     = "${local.project_id}-app"
  location = local.project_default_region
  project  = local.project_id
}

resource "google_storage_bucket_object" "zip" {
  source       = data.archive_file.source.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files's content
  # to force the zip to be updated as soon as a change occurs
  name   = "src-${data.archive_file.source.output_md5}.zip"
  bucket = google_storage_bucket.function_bucket.name

  # Dependencies are automatically inferred so these lines can be deleted
  depends_on = [
    google_project_service.gcp_services,
    google_storage_bucket.function_bucket, # declared in `storage.tf`
    data.archive_file.source
  ]
}

resource "google_app_engine_application" "app" {
  project     = local.project_id
  location_id = "europe-west"
}

resource "google_app_engine_standard_app_version" "app_v1" {
  project    = local.project_id
  version_id = "v1"
  service    = "default"
  runtime    = "nodejs16"
  delete_service_on_destroy = true

  entrypoint {
    shell = "npm start"
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.function_bucket.name}/${google_storage_bucket_object.zip.name}"
    }
  }
  
  env_variables = {
    PROJECT_ID    = local.project_id
    CLIENT_ID = local.web_application_client_id
    CLIENT_SECRET = local.web_application_client_secret
  }
/*
  automatic_scaling {
    max_concurrent_requests = 10
    min_idle_instances      = 1
    max_idle_instances      = 3
    min_pending_latency     = "1s"
    max_pending_latency     = "5s"
    standard_scheduler_settings {
      target_cpu_utilization        = 0.5
      target_throughput_utilization = 0.75
      min_instances                 = var.min_instances
      max_instances                 = var.max_instances
    }
  }

  vpc_access_connector {
    name = google_vpc_access_connector.connector.self_link
  }*/
}


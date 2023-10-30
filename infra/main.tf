# Bucket to store website

resource "google_storage_bucket" "website" {
  name = "example-website-by-linus"
  location = "ASIA"
}

# Make new objects public
resource "google_storage_object_access_control" "public_rule" {
  object = google_storage_bucket_object.static_site_src.output_name
  bucket = google_storage_bucket.website.name
  role   = "READER"
  entity = "allUsers"
}
#resource "google_storage_default_object_access_control" "website_read" {
#  bucket = google_storage_bucket.website.name
#  role   = "READER"
#  entity = "allUsers"
#}

# Upload the html file to the bucket
resource "google_storage_bucket_object" "static_site_src" {
  name   = "index.html"
  source = "../website/index.html"
  bucket = google_storage_bucket.website.name

}

# Reserve an external IP
resource "google_compute_global_address" "website" {
  name     = "website-lb-ip"
}

# Add the bucket as a CDN backend
resource "google_compute_backend_bucket" "website-backend" {
  name        = "website-backend"
  description = "Contains files needed by the website"
  bucket_name = google_storage_bucket.website.name
  enable_cdn  = true
}

## Create HTTPS certificate
#resource "google_compute_managed_ssl_certificate" "website" {
#  provider = google-beta
#  name     = "website-cert"
#  managed {
#    domains = [google_dns_record_set.website.name]
#  }
#}

# GCP URL MAP
resource "google_compute_url_map" "website" {
  name            = "website-url-map"
  default_service = google_compute_backend_bucket.website-backend.self_link
  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_bucket.website-backend.self_link
  }
}

# GCP target proxy
resource "google_compute_target_http_proxy" "website" {
  name             = "website-target-proxy"
  url_map          = google_compute_url_map.website.self_link
}

# GCP forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "website-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.website.address
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.website.self_link
}
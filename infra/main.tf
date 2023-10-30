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
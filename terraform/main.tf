# Specify the provider and access details

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.aws_region}"
}

# Declare the data source
data "aws_availability_zones" "available" {}

data "aws_availability_zones" "available" {
  state = "available"
  exclude_names = local.blacklist_az
}

locals  {
  availability_zones = data.aws_availability_zones.available.names
}

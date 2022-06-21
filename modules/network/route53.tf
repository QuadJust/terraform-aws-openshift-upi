data "aws_route53_zone" "public" {
  name = local.cluster_base_domain
}

resource "aws_route53_record" "api_public" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "api.${local.cluster_domain}"
  type    = "A"

  alias {
    name                   = aws_lb.ext.dns_name
    zone_id                = aws_lb.ext.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_zone" "private" {
  name = local.cluster_domain

  vpc {
    vpc_id = aws_vpc.cluster.id
  }

  tags = merge({
    Name = "${local.cluster_id}-int",
  }, local.cluster_tag)
}

resource "aws_route53_record" "api_public_private" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "api.${local.cluster_domain}"
  type    = "A"

  alias {
    name                   = aws_lb.ext.dns_name
    zone_id                = aws_lb.ext.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api_private" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "api-int.${local.cluster_domain}"
  type    = "A"

  alias {
    name                   = aws_lb.int.dns_name
    zone_id                = aws_lb.int.zone_id
    evaluate_target_health = false
  }
}

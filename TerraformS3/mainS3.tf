provider "aws" {
  region        = "${var.aws_region}"
}

#S3 log bucket
resource "aws_s3_bucket" "log_bucket" {
  bucket        = "alba-tf-log-bucket"
  acl           = "log-delivery-write"

  #lifecycle rules

  lifecycle_rule {
    id            = "Logs"
    enabled       = var.lifecycle_rule_enabled_2

    prefix        = "log/"
    
    tags          = {
     
      owner       = "Alba"
      rule        = "log"
      autoclean   = "true"
    }

    #CURRENT VERSION
    transition {
      days          = 30
      storage_class = "STANDARD_IA" # or ONEZONE_IA
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days          = 90
    }
    
  }
  
}

#S3 bucket
resource "aws_s3_bucket" "myS3bucket" {
  bucket        = "alba-tf-test-bucket"
  acl           = "private"
  count         = var.enabled ? 1 : 0

  #versioning

  versioning {
    enabled     = var.versioning_enabled
  }

  #Logs

  logging {
    target_bucket = "${aws_s3_bucket.log_bucket.id}"
    target_prefix = "log/"
  }

  #lifecycle rules

  lifecycle_rule {
    id            = "bucketLifecylce"
    enabled       = var.lifecycle_rule_enabled

    prefix        = var.lifecycle_prefix
    
    tags          = {
     
      owner       = "Alba"
      rule        = "allS3"
      autoclean   = "true"
    }

    #NON CURRENT VERSION
    noncurrent_version_expiration {
      days          = 30
      storage_class = "ONEZONE_IA"
    }

    noncurrent_version_transition {
      days          = 60
      storage_class = "GLACIER"
    }

    #CURRENT VERSION
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days          = 90
    }
    
  } #end of lifecycle rules

  #LOGGING
  logging {
    target_bucket = "${aws_s3_bucket.log_bucket.id}"
    target_prefix = "log/"
  }
  
  #Tags for S3 bucket
  tags = {
    Name        = "Alba's bucket"
    Environment = "Dev"
  }
}

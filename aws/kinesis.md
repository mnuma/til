## KinesisでS3転送するときにディレクトリがUTC基準となり扱いにくい問題

processing_configuration を使って動的パーティショニングを行うことで解決可能

- 以下のようなJST基準のログに沿ってS3への転送を動的パーティショニングを使って行う場合。

```
{"time":"2023-05-26T09:04:46+09:00"}
```

- 以下はTerraformの例


```tf
resource "aws_kinesis_firehose_delivery_stream" "hoge_access_logs" {
  name        = "${var.env_name}-hoge-web-access-logs"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_delivery_role.arn
    bucket_arn          = "arn:aws:path-to-s3"
    buffer_size         = 64
    buffer_interval     = 60
    prefix              = "/nginx/access/!{partitionKeyFromQuery:year}-!{partitionKeyFromQuery:month}-!{partitionKeyFromQuery:day}/"
    error_output_prefix = "/nginx/access/result=!{firehose:error-output-type}/!{timestamp:yyyy-MM-dd/}"
    compression_format  = "GZIP"
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.kinesis.id
      log_stream_name = "DestinationDelivery"
    }

    processing_configuration {
      enabled = true

      processors {
        type = "MetadataExtraction"

        parameters {
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{year: .time[0:4],month: .time[5:7],day: .time[8:10]}"
        }
        parameters {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        }
      }
    }

    dynamic_partitioning_configuration {
      enabled = true
    }
  }

  server_side_encryption {
    enabled = true
  }
}
```

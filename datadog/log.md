
### RDS slowqueryログ向けGrokパーサー

```
ruile ^\# Time: %{date("yyMMdd  H:mm:ss"):date}\n+\# User@Host: %{notSpace: user1}\[%{notSpace: user2}\] @  \[%{ip: host}\]  Id:[\x20\t]+%{number: id}\n+\# Query_time: %{number: query_time}  Lock_time: %{number: lock_time} Rows_sent: %{number: rows_sent}  Rows_examined: %{number: rows_examined}\n+ *SET timestamp=%{number: timestamp};\n+%{data:query}
ruile ^\# Time: %{date("yyMMdd HH:mm:ss"):date}\n+\# User@Host: %{notSpace: user1}\[%{notSpace: user2}\] @  \[%{ip: host}\]  Id:[\x20\t]+%{number: id}\n+\# Query_time: %{number: query_time}  Lock_time: %{number: lock_time} Rows_sent: %{number: rows_sent}  Rows_examined: %{number: rows_examined}\n+ *SET timestamp=%{number: timestamp};\n+%{data:query}
```



### ログアラートでホワイトリスト的なものを実装する


```hcl
resource "datadog_monitor" "openresty_logs" {
  name    = "Error logs counts exceeds threshold. ${var.env} openresty"
  type    = "log alert"
  message = var.slack_channel

  query = "logs(\"env:${var.env} service:${var.service_name} -@http.url_details.path:(${join(" OR ", [for s in var.exclusion_url_paths : "${s}"])})\").index(\"main\").rollup(\"count\").by(\"status\").last(\"5m\") >= 10"

  monitor_thresholds {
    warning  = 5
    critical = 10
  }

  enable_logs_sample = true

  tags = [
    "env:${var.env}-${var.service_name}"
  ]
}
```

```hcl
variable "exclusion_url_paths" {
  type = list(string)

  default = [
    "/api/iwantexclusionthis"
  ]
}
```

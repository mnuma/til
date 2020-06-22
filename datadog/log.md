
### RDS slowqueryログ向けGrokパーサー

```
ruile ^\# Time: %{date("yyMMdd  H:mm:ss"):date}\n+\# User@Host: %{notSpace: user1}\[%{notSpace: user2}\] @  \[%{ip: host}\]  Id:[\x20\t]+%{number: id}\n+\# Query_time: %{number: query_time}  Lock_time: %{number: lock_time} Rows_sent: %{number: rows_sent}  Rows_examined: %{number: rows_examined}\n+ *SET timestamp=%{number: timestamp};\n+%{data:query}
ruile ^\# Time: %{date("yyMMdd HH:mm:ss"):date}\n+\# User@Host: %{notSpace: user1}\[%{notSpace: user2}\] @  \[%{ip: host}\]  Id:[\x20\t]+%{number: id}\n+\# Query_time: %{number: query_time}  Lock_time: %{number: lock_time} Rows_sent: %{number: rows_sent}  Rows_examined: %{number: rows_examined}\n+ *SET timestamp=%{number: timestamp};\n+%{data:query}
```

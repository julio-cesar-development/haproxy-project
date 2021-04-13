
# Limit connections by IP

This will drop connections when some IP try to open connections more than 10 times concurrently

```bash
stick-table type ip size 100k expire 5m store conn_cur,conn_rate(3s)
http-request track-sc0 src
acl is_conn_cur_exceeded src_conn_cur ge 10
acl is_conn_rate_exceeded src_conn_rate ge 30
http-request deny if is_conn_cur_exceeded
```

Tests

```bash
# AB
# -n requests     Number of requests to perform
# -c concurrency  Number of multiple requests to make at a time

# the amount of failed requests could vary

ab -c 1 -n 100 http://localhost:8000/
# Failed requests:        0

ab -c 10 -n 100 http://localhost:8000/
# Failed requests:        5

ab -c 100 -n 100 http://localhost:8000/
# Failed requests:        65
```

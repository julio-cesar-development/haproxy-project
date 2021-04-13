
# Limit connections by IP

This will drop connections when there is more than 30 requests made inside a small period of time (30 seconds this case)

```bash
stick-table type ip size 100k expire 5m store conn_cur,conn_rate(3s)
http-request track-sc0 src
acl is_conn_cur_exceeded src_conn_cur ge 10
acl is_conn_rate_exceeded src_conn_rate ge 30
http-request deny if is_conn_rate_exceeded
```

Tests

```bash
# on the request greater than or equal to 30 it will start failing
declare -i COUNTER
let "COUNTER=0"

while true; do
  let "COUNTER+=1"
  if [ $COUNTER -ge 50 ]; then
    break
  fi

  echo "COUNTER => $COUNTER"

  curl --silent http://localhost:8000
  echo
done
```

# Haproxy healthcheck

```bash
# healthcheck options
inter => check interval
downinter => check interval in down state
fall => failed checks to remove from pool
rise => successful checks to add again to pool

# e.g.:
check inter 10s downinter 1m fall 3 rise 2


# default check option (L4)
option tcp-check
# optional check option (L7)
option httpchk GET /


# testing
curl http://localhost:8000
# api_v1
# api_v2

docker-compose stop api_v2

curl http://localhost:8000
# api_v1
# api_v1

docker-compose up -d api_v2

# after 2 successful checks in 2 minutes
curl http://localhost:8000
# api_v1
# api_v2
```

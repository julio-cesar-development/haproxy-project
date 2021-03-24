# Haproxy with ACLs

> https://cbonte.github.io/haproxy-dconv/2.3/configuration.html#7

```bash
docker-compose up -d

#### regular backend
curl -X GET --url localhost:8000
# Nginx v1
# Nginx v2


#### with URL paths
curl -X GET --url localhost:8000/v1
# Nginx v1

curl -X GET --url localhost:8000/v2
# Nginx v2


#### with URL query params
curl -X GET --url localhost:8000?region=sa_east_1
# Nginx v1

curl -X GET --url localhost:8000?region=us_east_1
# Nginx v2


#### redirect to another address based on host header
curl -L -X GET -H 'Host: ifconfig.me' --url localhost:8000
# YOUR IPv4
```

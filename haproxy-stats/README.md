# Haproxy with ACLs

> https://cbonte.github.io/haproxy-dconv/2.3/configuration.html#7

```bash
docker-compose up -d

# APIs
curl -X GET --url localhost:8000
# API v1
# API v2
# API v3

echo -n 'admin:password' | base64
# YWRtaW46cGFzc3dvcmQ=

# metrics
curl -X GET \
  -H 'Authorization: Basic YWRtaW46cGFzc3dvcmQ=' \
  --url 'localhost:8888/metrics\;csv'
```

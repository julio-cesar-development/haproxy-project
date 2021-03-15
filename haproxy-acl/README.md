# Haproxy with ACLs

> https://cbonte.github.io/haproxy-dconv/2.3/configuration.html#7

```bash
docker-compose up -d


# CRYPT a password
htpasswd -dnb admin password
admin:vAJYCgPhTjlYw

echo -n 'admin:password' | base64
# YWRtaW46cGFzc3dvcmQ=


# Route without Basic Auth
curl -X GET --url localhost:8000
# 401 Unauthorized


# Route with Basic Auth
curl -X GET \
  -H 'Authorization: Basic YWRtaW46cGFzc3dvcmQ=' \
  --url localhost:8000
# API v1
# API v2
# API v3


#### Route based on HTTP Method ####
curl -X POST \
  -H 'Authorization: Basic YWRtaW46cGFzc3dvcmQ=' \
  --url localhost:8000
# 403 Forbidden Method

curl --head \
  -H 'Authorization: Basic YWRtaW46cGFzc3dvcmQ=' \
  --url localhost:8000
# HTTP/1.1 200 OK


#### Route based on Path ####
curl -X GET \
  -H 'Authorization: Basic YWRtaW46cGFzc3dvcmQ=' \
  --url localhost:8000/index.html
# 403 Forbidden Path


#### Route based on Header ####
curl -X GET \
  -H 'Authorization: Basic YWRtaW46cGFzc3dvcmQ=' \
  -H 'Host: apiv1.haproxy.local' --url localhost:8000
# API v1
# API v1
# API v1

curl -X GET \
  -H 'Authorization: Basic YWRtaW46cGFzc3dvcmQ=' \
  -H 'Host: apiv2.haproxy.local' --url localhost:8000
# API v2
# API v2
# API v2

curl -X GET \
  -H 'Authorization: Basic YWRtaW46cGFzc3dvcmQ=' \
  -H 'Host: apiv3.haproxy.local' --url localhost:8000
# API v3
# API v3
# API v3
```

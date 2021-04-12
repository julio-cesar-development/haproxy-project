# Haproxy with ACLs

> https://cbonte.github.io/haproxy-dconv/2.3/configuration.html#7

## Running

```bash
docker-compose up -d
```

## Haproxy Config

```bash
# haproxy config
userlist valid-users
        user ${AUTH_USERNAME} password ${AUTH_PASSWORD}

frontend proxy
        # ACL itself
        acl valid_users http_auth(valid-users)
        # handle the requests
        http-request auth realm Authorized if !valid_users
        # or...
        http-request auth realm Authorized unless valid_users
```

## Commands

```bash
# CRYPT a password
# -n  Don't update file; display results on stdout.
# -b  Use the password from the command line rather than prompting for it.

# algorithms
# -d  Force CRYPT encryption of the password (8 chars max, insecure)

# not supported by haproxy
# -m  Force MD5 encryption of the password (default)
# -B  Force bcrypt encryption of the password (very secure)

# htpasswd
htpasswd -dnb admin 'password' | head -1 | cut -d ':' -f2
# vAJYCgPhTjlYw

# SHA256 openssl
echo 'password' | openssl passwd -5 -stdin
# $5$i3q8RODXNTTjQw5w$bp8IY0cn27JrH021seCKEHRndn0a502KHT9cBicE820


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

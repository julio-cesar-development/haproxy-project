# Haproxy cookie session

```bash
# redispatch option, this is for redirecting to another server when the requested one is down, even if user has a stickiness cookie
option redispatch


# testing
docker-compose up -d

# send request and save cookies in a file
curl -I http://localhost:8000 --cookie-jar COOKIES
# HTTP/1.1 200 OK
# date: Sat, 27 Mar 2021 02:23:33 GMT
# content-length: 6
# content-type: text/plain; charset=utf-8
# set-cookie: BACKEND_NAME=apiv1; path=/
# cache-control: private

cat COOKIES
# localhost       FALSE   /       FALSE   0       BACKEND_NAME    apiv1

# send request with saved cookies
curl http://localhost:8000 --cookie COOKIES
# api_v1
# api_v1

# request without cookies
curl http://localhost:8000
# api_v1
# api_v2
```

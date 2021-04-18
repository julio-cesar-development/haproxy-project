# Haproxy Stats with Socket

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


# the following config on haproxy.cfg enables socket stats
stats   socket /var/lib/haproxy/stats level admin


# access socat container to send commands to haproxy
docker container exec -it socat sh

ls -lth /var/lib/haproxy/stats
# srwxr-xr-x    1 root     root           0 Apr 18 06:36 /var/lib/haproxy/stats

# get info from haproxy through socket
echo "show info" | socat stdio /var/lib/haproxy/stats

# disable a server
echo "disable server servers/apiv1" | socat stdio /var/lib/haproxy/stats

# enable a server
echo "enable server servers/apiv1" | socat stdio /var/lib/haproxy/stats

# set server's state
echo "set server servers/apiv1 state ready" | socat stdio /var/lib/haproxy/stats

# show sticky table
echo "show table" | socat stdio /var/lib/haproxy/stats
echo "show table [TABLE_NAME]" | socat stdio /var/lib/haproxy/stats

# clear a table
echo "clear table [TABLE_NAME]" | socat stdio /var/lib/haproxy/stats
```

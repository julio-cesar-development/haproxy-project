#!/bin/bash

touch /var/log/haproxy.log

cat /tmp/haproxy.cfg | envsubst \${PROXY_UI_USERNAME},\${PROXY_UI_PASSWORD} | tee /etc/haproxy/haproxy.cfg

/etc/init.d/haproxy start &
wait

exec "$@"

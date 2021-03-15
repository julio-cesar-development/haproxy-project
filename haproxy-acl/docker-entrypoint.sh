#!/bin/bash

touch /var/log/haproxy.log

cat /tmp/haproxy.cfg | envsubst \${AUTH_USERNAME},\${AUTH_PASSWORD} | tee /etc/haproxy/haproxy.cfg

/etc/init.d/haproxy start &
wait

exec "$@"

#!/bin/bash

touch /var/log/haproxy.log

# if we want to encrypt inside the container
# AUTH_PASSWORD=$(echo "${AUTH_PASSWORD}" | openssl passwd -5 -stdin)

cat /tmp/haproxy.cfg | envsubst \${AUTH_USERNAME},\${AUTH_PASSWORD} | tee /etc/haproxy/haproxy.cfg

/etc/init.d/haproxy start &
wait

exec "$@"

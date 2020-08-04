#!/bin/bash

touch /var/log/haproxy_0.log

service haproxy start &
wait

exec "$@"

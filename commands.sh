#!/bin/bash

# Build haproxy image
# docker image build -f Dockerfile -t juliocesarmidia/haproxy-project:latest .

# Run haproxy
# docker container run --rm --name haproxy-project --publish 8888:80 juliocesarmidia/haproxy-project:latest

# Push haproxy image
# docker image push juliocesarmidia/haproxy-project:latest

# commands
# /etc/haproxy/haproxy.cfg

# service haproxy start
# systemctl is-enabled haproxy
# journalctl --unit haproxy

# service haproxy status
# service haproxy restart

# curl http://172.200.10.3:9000/api/v1
# HTTP API 0

# curl http://172.200.10.4:9000/api/v1
# HTTP API 1

# curl http://http-api:9000/api/v1
# HTTP API 0 | HTTP API 1

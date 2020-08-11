# HAProxy Project

[![GitHub Status](https://badgen.net/github/status/julio-cesar-development/haproxy-project)](https://github.com/julio-cesar-development/haproxy-project)
![License](https://badgen.net/badge/license/MIT/blue)

> This is a simple project to try out HAProxy to load balancing requests using least connection algorithm.<br>

---

## Instructions

> Running

```bash
docker-compose up
```

## Tests

```bash
# this will reach the cluster with 3 cotainers (v1, v2, v3) using the default_backend of Haproxy
curl http://localhost:8000/

# this will reach the v4 server (using virtual hosting)
curl -H 'Host: api.haproxy.local' http://localhost:8000

# benchmark
docker run --rm --net=host \
  jordi/ab -c 256 -n 10000 \
  http://localhost:8000/
```

## Docs

> HAProxy

[https://phcco.com/alta-disponibilidade-e-balanceamento-de-carga-http-com-haproxy](https://phcco.com/alta-disponibilidade-e-balanceamento-de-carga-http-com-haproxy)<br>
[https://www.haproxy.com/blog/introduction-to-haproxy-logging/](https://www.haproxy.com/blog/introduction-to-haproxy-logging/)<br>
[https://cbonte.github.io/haproxy-dconv/1.8/configuration.html#2.4](https://cbonte.github.io/haproxy-dconv/1.8/configuration.html#2.4)<br>
[https://www.haproxy.org/download/1.4/doc/configuration.txt](https://www.haproxy.org/download/1.4/doc/configuration.txt)<br>
[https://www.haproxy.com/documentation/hapee/2-1r1/traffic-management/health-checking/](https://www.haproxy.com/documentation/hapee/2-1r1/traffic-management/health-checking/)<br>

## Authors

[Julio Cesar](https://github.com/julio-cesar-development)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

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
# benchmark
docker run --rm --net=host \
  jordi/ab -c 256 -n 10000 \
  http://localhost:8888/
```

## Docs

> HAProxy

[https://phcco.com/alta-disponibilidade-e-balanceamento-de-carga-http-com-haproxy](https://phcco.com/alta-disponibilidade-e-balanceamento-de-carga-http-com-haproxy)<br>
[https://www.haproxy.com/blog/introduction-to-haproxy-logging/](https://www.haproxy.com/blog/introduction-to-haproxy-logging/)<br>
[https://cbonte.github.io/haproxy-dconv/1.8/configuration.html#2.4](https://cbonte.github.io/haproxy-dconv/1.8/configuration.html#2.4)<br>
[https://www.haproxy.org/download/1.4/doc/configuration.txt](https://www.haproxy.org/download/1.4/doc/configuration.txt)<br>

## Authors

[Julio Cesar](https://github.com/julio-cesar-development)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

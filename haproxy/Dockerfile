FROM juliocesarmidia/ubuntu_base_alpine:18.04
LABEL maintainer="julio@blackdevs.com.br"

RUN apt-get update -yqq && \
    apt-get install -yqq haproxy rsyslog

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "/usr/bin/tail", "-f", "/var/log/haproxy_0.log" ]

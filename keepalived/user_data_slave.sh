#!/bin/bash

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
  echo "starting user-data $0"

  sleep 10

  echo "Enabling IP forwarding and dynamic address and bridge iptables"
  echo 1 > /proc/sys/net/ipv4/ip_forward
  echo 1 > /proc/sys/net/ipv4/ip_dynaddr
  echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables

  modprobe br_netfilter 2> /dev/null
  sysctl --system

  yum update -y
  yum install -y \
    gcc-c++ pcre-static pcre-devel systemd-devel \
    curl make autoconf automake libnl3-devel openssl-devel \
    ipset-devel file-devel net-snmp-devel glib2-devel pcre2-devel \
    libsystemd-devel libmnldevel libnftnl-devel iptables-devel

  # haproxy
  curl http://www.haproxy.org/download/2.3/src/haproxy-2.3.4.tar.gz --output /tmp/haproxy-2.3.4.tar.gz
  tar xvzf /tmp/haproxy-2.3.4.tar.gz -C /tmp
  cd /tmp/haproxy-2.3.4

  make TARGET=linux-glibc USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1 USE_CRYPT_H=1 USE_LIBCRYPT=1 USE_SYSTEMD=1
  make install

  mkdir -p /etc/haproxy
  mkdir -p /var/lib/haproxy/dev

  groupadd haproxy
  useradd haproxy -g haproxy

  chown -R haproxy: /var/lib/haproxy

  cat > /etc/sysconfig/haproxy <<EOF
CONFIG=/etc/haproxy/haproxy.cfg
PIDFILE=/run/haproxy.pid
EOF

  cat > /usr/lib/systemd/system/haproxy.service <<EOF
[Unit]
Description=HAProxy Load Balancer
After=network-online.target
Wants=network-online.target
[Service]
EnvironmentFile=/etc/sysconfig/haproxy
ExecStartPre=/usr/local/sbin/haproxy -c -f \$CONFIG
ExecStart=/usr/local/sbin/haproxy -Ws -f \$CONFIG -p \$PIDFILE
ExecReload=/bin/kill -USR2 \$MAINPID
SuccessExitStatus=143
KillMode=mixed
Type=notify
[Install]
WantedBy=multi-user.target
EOF

  cat > /etc/haproxy/haproxy.cfg <<EOF
global
  log /dev/log local0
  chroot /var/lib/haproxy
  user haproxy
  group haproxy
  daemon
  maxconn 256

defaults
  log global
  option dontlognull
  timeout queue 1m
  timeout connect 10s
  timeout client 1m
  timeout server 1m
  timeout check 10s
  maxconn 3000

frontend front
  bind *:80
  default_backend servers

backend servers
  server nginx1 ${NGINX_IP}:80

EOF

  systemctl daemon-reload
  systemctl enable haproxy
  # systemctl stop haproxy
  systemctl start haproxy
  systemctl status haproxy
  # journalctl --unit haproxy -f

  cd ~

  # keepalived
  curl https://keepalived.org/software/keepalived-2.2.0.tar.gz --output /tmp/keepalived-2.2.0.tar.gz
  tar xvzf /tmp/keepalived-2.2.0.tar.gz -C /tmp
  cd /tmp/keepalived-2.2.0
  ./configure
  make
  make install

  mkdir -p /etc/keepalived

  cat > /etc/keepalived/keepalived.conf <<EOF
vrrp_track_process haproxy {
  process haproxy
  quorum 1
  delay 5
}

vrrp_instance VRRP1 {
  state BACKUP
  interface eth0
  virtual_router_id 41
  priority 100
  advert_int 1
  virtual_ipaddress {
    ${VIRTUAL_IP}/24
  }
  track_process {
    haproxy
  }
}
EOF

  systemctl daemon-reload
  systemctl enable keepalived
  # systemctl stop keepalived
  systemctl start keepalived
  systemctl status keepalived
  # journalctl --unit keepalived -f

  # add route for keepalived CIDR
  ip route add ${VIRTUAL_IP}/30 dev eth0

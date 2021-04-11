# Haproxy with SSL

> Generating self signed certificate

```bash
mkdir -p certs && cd $_

openssl req -newkey \
  rsa:2048 -nodes \
  -keyout key.pem \
  -x509 -days 365 \
  -out certificate.pem

# create the file with both key and certificate to Haproxy
cat key.pem | cat - <(cat certificate.pem) > full.pem

cd ..

echo "172.100.0.2 haproxy.blackdevs.local" >> /etc/hosts

# this will return nothing, it needs to allow redirect
curl http://172.100.0.2

# using HTTP, being redirected to HTTPS
# -L allow redirect
# -k ignore self signed certificate
curl -k -L http://haproxy.blackdevs.local
# api_v1
# api_v2

# trying out HTTPS
# -k ignore self signed certificate
curl -k https://haproxy.blackdevs.local
# api_v1
# api_v2

# trying out with openssl
openssl s_client -connect 172.100.0.2:443 -debug -msg

# remove config
sed -ri 's/172\.100\.0\.2.*//gi' /etc/hosts
```

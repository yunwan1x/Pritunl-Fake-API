mkdir -p /etc/ssl/private /etc/ssl/certs

# 1. 生成根证书私钥和自签名证书(10年有效期)
openssl req -x509 -nodes -days 36500 -newkey rsa:4096 \
  -keyout /etc/ssl/private/ca.key \
  -out /etc/ssl/certs/ca.crt \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=MyOrg/OU=IT/CN=MyRootCA"

echo "✓ 根证书已生成"

# 2. 安装根证书到Alpine系统
cp /etc/ssl/certs/ca.crt /usr/local/share/ca-certificates/myca.crt
update-ca-certificates

echo "✓ 根证书已安装到系统"

# 3. 生成服务器私钥
openssl genrsa -out /etc/ssl/private/server.key 4096

echo "✓ 服务器私钥已生成"

# 4. 创建证书签名请求配置文件
cat > /tmp/server.conf <<EOF
[req]
default_bits = 4096
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = req_ext

[dn]
C=CN
ST=Beijing
L=Beijing
O=MyOrg
OU=IT
CN=127.0.0.1

[req_ext]
subjectAltName = @alt_names

[alt_names]
IP.1 = 127.0.0.1
DNS.1 = localhost
EOF

# 5. 生成证书签名请求(CSR)
openssl req -new -key /etc/ssl/private/server.key \
  -out /tmp/server.csr \
  -config /tmp/server.conf

echo "✓ CSR已生成"

# 6. 创建签名扩展配置
cat > /tmp/v3.ext <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
IP.1 = 127.0.0.1
DNS.1 = localhost
EOF

# 7. 使用根证书签发服务器证书(100年有效期)
openssl x509 -req -in /tmp/server.csr \
  -CA /etc/ssl/certs/ca.crt \
  -CAkey /etc/ssl/private/ca.key \
  -CAcreateserial \
  -out /etc/ssl/certs/server.crt \
  -days 36500 \
  -sha256 \
  -extfile /tmp/v3.ext

echo "✓ 服务器证书已签发(100年有效期)"

# 8. 设置权限
chmod 600 /etc/ssl/private/*.key
chmod 644 /etc/ssl/certs/*.crt
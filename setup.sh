echo "install pre required packages"
apt update
apt-get install -y git libgnutls28-dev libev-dev libpam0g-dev liblz4-dev libseccomp-dev \
        libreadline-dev libnl-route-3-dev libkrb5-dev libradcli-dev \
        libcurl4-gnutls-dev libcjose-dev libjansson-dev libprotobuf-c-dev \
        libtalloc-dev libhttp-parser-dev protobuf-c-compiler gperf \
        nuttcp lcov libuid-wrapper libpam-wrapper libnss-wrapper \
        libsocket-wrapper gss-ntlmssp haproxy iputils-ping freeradius \
        gawk gnutls-bin iproute2 yajl-tools tcpdump
echo "install pre required packages done..."
echo "enable ip forwarding"
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
echo "cloning code"
git clone https://gitlab.com/openconnect/ocserv.git
echo "ok, compiling"
cd ocserv/
autoreconf -fvi
./configure && make && make install
cd ..
certtool --generate-privkey --outfile ca-key.pem
certtool --generate-self-signed --load-privkey ca-key.pem --template ca.tmpl --outfile ca-cert.pem
certtool --generate-privkey --outfile server-key.pem
certtool --generate-certificate --load-privkey server-key.pem --load-ca-certificate ca-cert.pem --load-ca-privkey ca-key.pem --template server.tmpl --outfile server-cert.pem
mkdir /etc/ocserv
cp server-cert.pem /etc/ocserv/
cp server-key.pem /etc/ocserv/
cp ca-key.pem /etc/ocserv/
cp ca-cert.pem /etc/ocserv/
cp ocserv.conf /etc/ocserv/
echo "setting up iptables"
iptables -t nat -A POSTROUTING -s 192.168.23.0/255.255.255.0 -j MASQUERADE
echo "enter your username:"
read username
ocpasswd -c /etc/ocserv/passwd $username
echo "starting ocserv"
ocserv

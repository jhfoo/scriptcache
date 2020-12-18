#!/usr/local/bin/zsh

SERVER_IP=192.168.80.3
SERVER_PUB_IP=spectrum.kungfoo.info
SERVER_WG_IP=192.168.81.1
SERVER_WG_PORT=51820

PEER_IP=192.168.81.10
PEER_IP_NET=24
PEER_DEST="192.168.0.0/24, 192.168.88.0/24"

DNS_IP=8.8.8.8
PATH_WG_CONFIG=/usr/local/etc/wireguard

generateKeys() {
  # generate keys
  wg genkey > server.priv
  wg pubkey < server.priv > server.pub
  wg genkey > peer.priv
  wg pubkey < peer.priv > peer.pub

  # capture public and private keys into variables
  SERVER_PUBKEY=$(cat server.pub)
  SERVER_PRIVKEY=`cat server.priv`
  PEER_PUBKEY=`cat peer.pub`
  PEER_PRIVKEY=`cat peer.priv`

  # generate file wg0.conf
  cat <<EOF > "$PATH_WG_CONFIG/wg0.conf"
[Interface]
Address = $SERVER_WG_IP/24
ListenPort = $SERVER_WG_PORT
PrivateKey = $SERVER_PRIVKEY
DNS = $DNS_IP

[Peer]
PublicKey = $PEER_PUBKEY
AllowedIPs = $PEER_IP/32
EOF
  cat $PATH_WG_CONFIG/wg0.conf

  # generate client.conf
  cat <<EOF > "client.conf"
[Interface]
Address = $PEER_IP/$PEER_IP_NET
PrivateKey = $PEER_PRIVKEY
DNS = 8.8.8.8

[Peer]
PublicKey = $SERVER_PUBKEY
AllowedIPs = $PEER_DEST
Endpoint = $SERVER_PUB_IP:$SERVER_WG_PORT
EOF
  cat client.conf
}

# prompt: generate keys
read "?Generate keys? [y/N] " IsGenerateKeys
if [[ $IsGenerateKeys =~ '^[Yy]' ]]
then
  echo "Generating keys..."
  generateKeys
fi

# prompt: update /etc/rc.conf
read "?Update /etc/rc.conf? [y/N] " IsUpdateRcConf
if [[ $IsUpdateRcConf =~ '^[Yy]' ]]
then
  sysrc wireguard_enable="YES"
  sysrc wireguard_interfaces=wg0
fi

read "?Start service now? [y/N] " IsStartService
if [[ $IsStartService =~ '^[Yy]' ]]
then
  service wireguard start
fi

# prompt: show QR code
read "?Show client config in QR Code? [y/N] " IsShowQrCode
if [[ $IsShowQrCode =~ '^[Yy]' ]]
then
  qrencode -t ansi < client.conf
else
fi



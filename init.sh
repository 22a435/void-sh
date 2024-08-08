#!/bin/sh

COMETRPC="https://penumbra-rpc.polkachu.com/"
MONIKER="node0"
USER=$(whoami)
IP=$(dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com)
IP="${IP%\"}"
IP="${IP#\"}"
DNS=$(dig @1.1.1.1 -x $IP +short)

curl --proto '=https' --tlsv1.2 -LsSf https://github.com/penumbra-zone/penumbra/releases/download/v0.80.0/pd-installer.sh | sh
sudo cp $HOME/.cargo/bin/pd /usr/local/bin/pd

$HOME/.cargo/bin/pd network join --moniker $MONIKER --external-address $IP:26656 $COMETRPC

#load snapshot (comment out to sync from genesis)
SNAPSHOT=$(curl --proto '=https' --tlsv1.2 -LsSf https://polkachu.com/api/v2/chain_snapshots/penumbra | jq -r ".snapshot.url")
curl --proto '=https' --tlsv1.2 -LsSf $SNAPSHOT | lz4 -c -d - | tar -x -C $HOME/.penumbra/network_data/node0

curl --proto '=https' --tlsv1.2 -LsSf https://raw.githubusercontent.com/penumbra-zone/penumbra/main/deployments/scripts/install-cometbft > install-cometbft.sh
sudo bash install-cometbft.sh

curl --proto '=https' --tlsv1.2 -LsSf https://raw.githubusercontent.com/penumbra-zone/penumbra/main/deployments/systemd/penumbra.service > penumbra.service
if [[ -n "$DNS" ]]; then
  sed -i -E "s+ExecStart=/usr/local/bin/pd start+ExecStart=/usr/local/bin/pd start --grpc-auto-https ${DNS::-1}+g" penumbra.service
fi
sed -i -E "s/User=penumbra/User=${USER}/g" penumbra.service
sudo cp penumbra.service /etc/systemd/system/penumbra.service

curl --proto '=https' --tlsv1.2 -LsSf https://raw.githubusercontent.com/penumbra-zone/penumbra/main/deployments/systemd/cometbft.service > cometbft.service
sed -i -E "s/User=penumbra/User=${USER}/g" cometbft.service
sed -i -E "s+ExecStart=/usr/local/bin/cometbft start --home /home/penumbra/.penumbra/network_data/node0/cometbft+ExecStart=/usr/local/bin/cometbft start --home $HOME/.penumbra/network_data/node0/cometbft+g" cometbft.service
sudo cp cometbft.service /etc/systemd/system/cometbft.service

sudo systemctl daemon-reload
sudo systemctl restart penumbra cometbft

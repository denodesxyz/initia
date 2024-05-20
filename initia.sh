#!/bin/bash

RED="\e[31m"
NOCOLOR="\e[0m"

while true
do

curl -s https://api.denodes.xyz/logo.sh | bash && sleep 1
echo ""
echo "Welcome to the Initia One-Liner Script! 🛠

Our goal is to simplify the process of running a Initia node.
With this script, you can effortlessly select additional options right from your terminal. 
"
echo ""

cd $HOME

touch $HOME/.bash_profile
source $HOME/.bash_profile

if [ ! $MONIKER ]; then
    read -p "Enter validator name: " MONIKER
fi
WALLET="wallet"

echo "export NAMADA_ALIAS="$MONIKER"" >> $HOME/.bash_profile
echo "export NAMADA_WALLET="$WALLET"" >> $HOME/.bash_profile
echo "export CHAIN_ID="initiation-1"" >> $HOME/.bash_profile
source $HOME/.bash_profile

apt update && sudo apt upgrade -y
apt install build-essential jq git -y

wget https://go.dev/dl/go1.22.3.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.22.3.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin" >> $HOME/.profile
source $HOME/.profile

git clone https://github.com/initia-labs/initia
cd initia
git checkout v0.2.15 
make build
cp build/initiad /usr/local/bin/

initiad init $MONIKER
initiad config set client chain-id initiation-1
initiad config set client keyring-backend test
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.15uinit,0.01uusdc\"|" $HOME/.initia/config/app.toml
wget -O $HOME/.initia/config/genesis.json https://initia.s3.ap-southeast-1.amazonaws.com/initiation-1/genesis.json
wget -O $HOME/.initia/config/addrbook.json https://initia.s3.ap-southeast-1.amazonaws.com/initiation-1/addrbook.json
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.initia/config/config.toml

PEERS="093e1b89a498b6a8760ad2188fbda30a05e4f300@35.240.207.217:26656,2c729d33d22d8cdae6658bed97b3097241ca586c@195.14.6.129:26019"
sed -i 's|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.initia/config/config.toml

SEEDS="2eaa272622d1ba6796100ab39f58c75d458b9dbc@34.142.181.82:26656,c28827cb96c14c905b127b92065a3fb4cd77d7f6@testnet-seeds.whispernode.com:25756"
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|' $HOME/.initia/config/config.toml

git clone https://github.com/skip-mev/slinky.git
cd slinky
git checkout v0.4.3
make build
cp build/slinky /usr/local/bin/slinky

sudo tee /etc/systemd/system/slinkyd.service > /dev/null <<EOF
[Unit]
Description=slinkyd

[Service]
Type=simple
ExecStart=/usr/local/bin/slinky start
Restart=on-failture
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=slinkyd
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable slinkyd
systemctl restart slinkyd

sudo tee /etc/systemd/system/initiad.service > /dev/null <<EOF
[Unit]
Description=initiad

[Service]
Type=simple
ExecStart=/usr/local/bin/initiad start
Restart=on-abort
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=initiad
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable initiad
systemctl restart initiad

if [[ `service initiad status | grep active` =~ "running" ]]; then
        echo -e "Your initia node installed and works"
        echo -e "You can check logs by the command: journalctl -fu initiad -o cat"
    else
        echo -e "Your initia node was not installed correctly. Please reinstall"
fi


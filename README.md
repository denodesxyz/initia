# initia
A simplified manual for running a Initia node.

### prerequisite

- CPU: **4 Cores**
- Memory: **16GB**
- Disk: **1 TB SSD***
- Machine: **Ubuntu 22.04+**

### script execution

Use the following script to install the node:
```
wget -O initia.sh https://api.denodes.xyz/initia.sh && bash initia.sh
```

After installation, wait for full synchronization. The command below should return `false`:
```
curl -s localhost:26657/status | jq .result.sync_info.catching_up
```
### wallet & faucet

Next, proceed to create a wallet and show its address:
```
source $HOME/.bash_profile
```
Create new wallet:
```
initiad keys add $WALLET
```
Be sure to keep the mnemonic in a secure place.

Restore existing wallet:
```
initiad keys add $WALLET --recover
```

Let's save the wallet address and the validator address:
```
WALLET_ADDRESS=$(initiad keys show $WALLET -a)
VALOPER_ADDRESS=$(initiad keys show $WALLET --bech val -a)
echo "export WALLET_ADDRESS="$WALLET_ADDRESS >> $HOME/.bash_profile
echo "export VALOPER_ADDRESS="$VALOPER_ADDRESS >> $HOME/.bash_profile
source $HOME/.bash_profile
```

Request test tokens from the [Faucet](https://faucet.testnet.initia.xyz/) for this address.
Then, check your balance:
```
initiad q bank balances $WALLET_ADDRESS
```

### validator initialization

Initialising a validator account:
```
initiad tx mstaking create-validator \
  --amount 1000000uinit \
  --pubkey $(initiad tendermint show-validator) \
  --moniker $MONIKER \
  --details "YOUR VALIDATOR DESCRIPTION (OPTIONAL)" \
  --website "YOUR WEBSITE (OPTIONAL)" \
  --chain-id initiation-1 \
  --commission-rate 0.07 \
  --commission-max-rate 0.20 \
  --commission-max-change-rate 0.05 \
  --from $WALLET \
  --fees 90000uinit \
  --gas auto \
  -y
```

## Useful Commands

Here are some handy commands:

- Check logs: `sudo journalctl -u initiad -f`
- Restart your node: `sudo systemctl restart initiad`
- Check a wallet balance: `initiad q bank balances $WALLET_ADDRESS`
- Check sync status: `curl -s localhost:26657/status | jq .result.sync_info.catching_up`

## Deleting Your Node

```
sudo systemctl stop initiad
sudo systemctl disable initiad
sudo rm -rf /etc/systemd/system/initiad.service
sudo rm $(which initiad)
sudo rm $(which slinky)
sudo rm -rf ~/.initia
sudo rm -rf ~/.slinky
sudo rm -rf ~/initia
sudo rm -rf ~/slinky
```

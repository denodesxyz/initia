# Initia
A simplified manual for running an Initia node.

### prerequisite

- CPU: **16 Cores**
- Memory: **16GB RAM**
- Disk: **2TB SSD***
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
echo "export WALLET_ADDRESS="$WALLET_ADDRESS >> $HOME/.bash_profile
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

Edit validator details:
```
initiad tx staking edit-validator \
  --commission-rate 0.08 \
  --new-moniker "$MONIKER" \
  --identity "NEW IDENTITY" \
  --details "NEW DESCRIPTION" \
  --from $WALLET \
  --chain-id initiation-1 \
  --fees 90000uinit \
  --gas auto \
  -y 
```

Unjail validator:
```
initiad tx slashing unjail --from $WALLET --chain-id initiation-1 --gas auto --fees 90000uinit -y
```

Vote proposal:
```
initiad tx gov vote 1 yes --from $WALLET --chain-id initiation-1  --gas auto --fees 90000uinit -y 
```

Withdraw all rewards:
```
initiad tx distribution withdraw-all-rewards --from $WALLET --chain-id initiation-1 --gas auto --fees 90000uinit -y
```

Withdraw rewards and commission from your validator:
```
initiad tx distribution withdraw-rewards $(initiad keys show $WALLET --bech val -a) --from $WALLET --commission --chain-id initiation-1 --gas auto --fees 90000uinit -y 
```

Delegate more tokens to yourself:
```
initiad tx staking delegate $(initiad keys show $WALLET --bech val -a) 1000000uinit --from $WALLET --chain-id initiation-1 --gas auto --fees 90000uinit -y 
```

Delegate tokens to another validator:
```
initiad tx staking delegate <TO_VALOPER_ADDRESS> 1000000uinit --from $WALLET --chain-id initiation-1 --gas auto --fees 90000uinit -y 	
```

Redelegate tokens from one validator to another:
```
initiad tx staking redelegate <FROM_VALOPER_ADDRESS> <TO_VALOPER_ADDRESS> 1000000uinit --from $WALLET --chain-id initiation-1 --gas auto --fees 90000uinit -y 
```

Transfer tokens to another address:
```
initiad tx bank send $(initiad keys show $WALLET -a) <TO_WALLET_ADDRESS> 1000000uinit --gas auto --fees 90000uinit -y 
```

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
sudo systemctl stop slinkyd
sudo systemctl disable slinkyd
sudo rm -rf /etc/systemd/system/slinkyd.service
sudo rm $(which initiad)
sudo rm $(which slinky)
sudo rm -rf ~/.initia
sudo rm -rf ~/.slinky
sudo rm -rf ~/initia
sudo rm -rf ~/slinky
```

Use the command in geth console to execute the scripts.

loadScript('/home/node1_admin/Desktop/EthereumCustomScripts/ContractDeploy.js')
loadScript('/home/node1_admin/Desktop/EthereumCustomScripts/AddAddress.js')
loadScript('/home/node1_admin/Desktop/EthereumCustomScripts/ContractUtilityFunctions.js')

0xf7599e6b94032f0dcf975e3141fc41193f322925

eth.getBlock("latest").gasLimit

Create Accounts with ether
----------------------------
for (var i = 0; i < 39; i++) {

var newAccount = personal.newAccount("password");
eth.sendTransaction({from: eth.coinbase, to: newAccount, value: web3.toWei(10000, "ether")})
}


for (var i = 1; i < 50; i++) {
eth.sendTransaction({from: eth.coinbase, to: eth.accounts[i], value: web3.toWei(10000, "ether")})
}

//unlock each account for infinite time
for (var i = 11; i < 51; i++) {
	personal.unlockAccount(eth.accounts[i], "password",-1);
};

Useful commands: 
-----------------
Get the Block gaslimit of network: 
eth.getBlock("latest").gasLimit

to mine once: 
miner.start(4);admin.sleepBlocks(1);miner.stop()

Maintenance Etherium code snippet:
------------------------------------
Backup the blocchain network (stop the network before backup/restore)
geth --datadir="/home/node1_admin/data2/Blockchain/DataDir" export "ethdatabackup1"

Removes blockchain & state database. basically affects only datadirectory
geth --datadir="/home/node1_admin/data2/Blockchain/DataDir" removedb

Restore the Blockchain network
geth --datadir="/home/node1_admin/data2/Blockchain/DataDir" import "ethdatabackup1"

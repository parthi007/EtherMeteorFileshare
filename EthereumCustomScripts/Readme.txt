Use the command in geth console to execute the scripts.

loadScript('/home/node1_admin/Desktop/EthereumCustomScripts/ContractDeploy.js')
loadScript('/home/node1_admin/Desktop/EthereumCustomScripts/AddAddress.js')
loadScript('/home/node1_admin/Desktop/EthereumCustomScripts/ContractUtilityFunctions.js')

0xf8bfef5475e8a5cdee0ae18c03aabeb602927e7d

0xf7599e6b94032f0dcf975e3141fc41193f322925

--to get a public value of the contract
useraccesscontrolcontract.addressCount.call()
useraccesscontrolcontract.GetAvailableAddresses.call()



eth.getBlock("latest").gasLimit

Create Accounts with ether
----------------------------
for (var i = 0; i < 300; i++) {

var newAccount = personal.newAccount("password");
eth.sendTransaction({from: eth.coinbase, to: newAccount, value: web3.toWei(10, "ether")})
}


for (var i = 1; i < 300; i++) {
eth.sendTransaction({from: eth.coinbase, to: eth.accounts[i], value: web3.toWei(10000, "ether")})
}

//unlock each account for infinite time
for (var i = 11; i < 51; i++) {
	personal.unlockAccount(eth.accounts[i], "password",-1);
};

//list all accounts
for (var i = 0; i < eth.accounts.length; i++) {
	console.log('"' + eth.accounts[i] + '": {"balance": "20000000000000000000"},')
};

Useful commands: 
-----------------
Get the Block gaslimit of network: 
eth.getBlock("latest").gasLimit

to mine once: 
miner.start(4);admin.sleepBlocks(1);miner.stop()

test a sample transaction:
eth.sendTransaction({from: eth.accounts[2], to: eth.accounts[1], value: web3.toWei(10000, "ether")})

eth.sendTransaction({from: eth.accounts[2], to: eth.accounts[1], value: 999999999999990000})


Get balance:
eth.getBalance(eth.accounts[0])
web3.fromWei(eth.getBalance(eth.accounts[0]),"ether")

check gas price:
web3.eth.gasPrice

Maintenance Etherium code snippet:
------------------------------------
Backup the blocchain network (stop the network before backup/restore)
geth --datadir="/home/node1_admin/data2/Blockchain/DataDir" export "ethdatabackup1"

Removes blockchain & state database. basically affects only datadirectory
geth --datadir="/home/node1_admin/data2/Blockchain/DataDir" removedb

Restore the Blockchain network
geth --datadir="/home/node1_admin/data2/Blockchain/DataDir" import "ethdatabackup1"


--to get all the accounts in a private network of a custom build geth
/home/node1_admin/LocalGeth/go-ethereum/build/bin/geth --identity "DellBCPN4" --datadir="/home/node1_admin/blockchaindata/DataDir16" account list

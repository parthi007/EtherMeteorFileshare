Use the command in geth console to execute the scripts.

loadScript('/home/node1_admin/Desktop/EthereumCustomScripts/ContractDeploy.js')
loadScript('/home/node1_admin/Desktop/EthereumCustomScripts/AddAddress.js')
loadScript('/home/node1_admin/Desktop/EthereumCustomScripts/ContractUtilityFunctions.js')

Create Accounts with ether
----------------------------
for (var i = 0; i < 39; i++) {

var newAccount = personal.newAccount("password");
eth.sendTransaction({from: eth.coinbase, to: newAccount, value: web3.toWei(10000, "ether")})
}


for (var i = 11; i < 51; i++) {
	personal.unlockAccount(eth.accounts[i], "password",-1);
};


"patient1","password","0xd6052dc439cc457b718aa2e16b3d0b888f29389d"
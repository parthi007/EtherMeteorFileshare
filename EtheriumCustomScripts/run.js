console.log("Load script to mine only when there is some pending transactions");

var mining_threads = 1

function checkWork() {
    if (eth.getBlock("pending").transactions.length > 0) {
        if (eth.mining) return;
        console.log("== Pending transactions! Mining...");
        miner.start(mining_threads);
    } else {
        miner.stop();
        console.log("== No transactions! Mining stopped.");
    }
}

eth.filter("latest", function(err, block) { checkWork(); });
eth.filter("pending", function(err, block) { checkWork(); });

checkWork();

console.log("Unlock all accounts");
var unlocked = personal.unlockAccount(eth.accounts[0], "password",-1);
personal.unlockAccount(eth.accounts[1], "password",-1);
personal.unlockAccount(eth.accounts[2], "password",-1);
personal.unlockAccount(eth.accounts[3], "password",-1);
personal.unlockAccount(eth.accounts[4], "password",-1);
personal.unlockAccount(eth.accounts[5], "password",-1);
personal.unlockAccount(eth.accounts[6], "password",-1);
personal.unlockAccount(eth.accounts[7], "password",-1);
personal.unlockAccount(eth.accounts[8], "password",-1);
personal.unlockAccount(eth.accounts[9], "password",-1);
personal.unlockAccount(eth.accounts[10], "password",-1);


console.log("mine once all pending transactions");
eth.pendingTransactions;

miner.start(4);admin.sleepBlocks(1);miner.stop();


var contractInstance;

var username, password, role;


Template['components_admin'].onRendered(function(){
    TemplateVar.set('state', {isInactive: true});
});


Template['components_admin'].events({

	"click #createbtn": function(event, template){ 
        TemplateVar.set('state', {isMining: true});
	
        username = template.find("#userName").value;
	password = template.find("#password").value;

        web3.eth.defaultAccount = web3.eth.coinbase;
       
        var transactionObject = {
            data: UserAccessControlContract.bytecode, 
            gasPrice: web3.eth.gasPrice,
            gas: 5000000,
            from: web3.eth.coinbase
        };
      

        web3.eth.estimateGas(transactionObject, function(err, estimateGas){
            if(!err)
                transactionObject.gas = estimateGas * 20;
            
            UserAccessControlContract.new(username, password, transactionObject, 
                                 function(err, contract){
                if(err)
                    return TemplateVar.set(template, 'state', {isError: true, error: String(err)});
                
                if(contract.address) {
                    TemplateVar.set(template, 'state', {isMined: true, address: contract.address});
                    contractInstance = contract;
                }
            });
        });
	},

    "click #addPatient": function(event, template){ 

        contractInstance = web3.eth.contract(UserAccessControlContract.abi).at(useraccesscontractaddr);
        
        var transactionObject = {
                data: UserAccessControlContract.bytecode, 
                        from: web3.eth.coinbase,
                    gasPrice: web3.eth.gasPrice,
                        gas: 500000
            };

        web3.eth.estimateGas(transactionObject, function(err, estimateGas){
        if(!err)
            transactionObject.gas = estimateGas * 10;
        
        roleCd = 2;
        nodeAddress = template.find("#nodeAddress").value;
        
            
        TemplateVar.set(template, 'state',{inProcess: true});
        contractInstance.AddAddress.sendTransaction(nodeAddress,roleCd,transactionObject, function(err,txAddress){

        if(err)
            return TemplateVar.set(template, 'state', {isError: true,error:String(err)});
        else
                    {
            var loggedEvent = contractInstance.AddressAdded();
            
                        var inter = setInterval(function() {
                        var pending =web3.eth.getBlock("pending").transactions.length;
                        if(pending==0)
                            {
                                loggedEvent.watch(function(error, result) {
                if (error) {
                    TemplateVar.set(template, 'state', {isAddedError: true});
                    return;
                }
                else
                {
                    if(result.args.added) {
                        TemplateVar.set(template, 'state', {isAdded: true});}
                    else
                    {
                        TemplateVar.set(template, 'state', {isAddFailed: true});
                    }
                    loggedEvent.stopWatching();
                }

                });
                               clearInterval(inter);
                            }},1000)
                    }
        });
            
        });
    },

        "click #addProvider": function(event, template){ 

        contractInstance = web3.eth.contract(UserAccessControlContract.abi).at(useraccesscontractaddr);
        
        var transactionObject = {
                data: UserAccessControlContract.bytecode, 
                        from: web3.eth.coinbase,
                    gasPrice: web3.eth.gasPrice,
                        gas: 500000
            };

        web3.eth.estimateGas(transactionObject, function(err, estimateGas){
        if(!err)
            transactionObject.gas = estimateGas * 10;
        
        roleCd = 3;
        nodeAddress = template.find("#nodeAddress").value;
        
            
        TemplateVar.set(template, 'state',{inProcess: true});
        contractInstance.AddAddress.sendTransaction(nodeAddress,roleCd,transactionObject, function(err,txAddress){

        if(err)
            return TemplateVar.set(template, 'state', {isError: true,error:String(err)});
        else
                    {
            var loggedEvent = contractInstance.AddressAdded();
            
                        var inter = setInterval(function() {
                        var pending =web3.eth.getBlock("pending").transactions.length;
                        if(pending==0)
                            {
                                loggedEvent.watch(function(error, result) {
                if (error) {
                    TemplateVar.set(template, 'state', {isAddedError: true});
                    return;
                }
                else
                {
                    if(result.args.added) {
                        TemplateVar.set(template, 'state', {isAdded: true});}
                    else
                    {
                        TemplateVar.set(template, 'state', {isAddFailed: true});
                    }
                    loggedEvent.stopWatching();
                }

                });
                               clearInterval(inter);
                            }},1000)
                    }
        });
            
        });
    }

});

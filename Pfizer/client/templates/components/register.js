var contractInstance;
var username, password;


Template['components_register'].events({

	"click #registerbtn": function(event, template){ 

		contractInstance = web3.eth.contract(UserAccessControlContract.abi).at(useraccesscontractaddr);
		
		var transactionObject = {
				data: UserAccessControlContract.bytecode, 
		            	from: web3.eth.accounts[0],
			    	gasPrice: web3.eth.gasPrice,
            			gas: 500000
	        };

		web3.eth.estimateGas(transactionObject, function(err, estimateGas){
		if(!err)
			transactionObject.gas = estimateGas * 10;
			
		
		username = template.find("#userName").value;	
		password = template.find("#password").value;
		roleCd = template.find("#rolelist").value;
		nodeAddress = template.find("#nodeAddress").value;
		
			
		TemplateVar.set(template, 'state',{inProcess: true});
		contractInstance.Register.sendTransaction(username, password,roleCd,nodeAddress,transactionObject, function(err,txAddress){

		if(err)
			return TemplateVar.set(template, 'state', {isError: true,error:String(err)});
		else
                    {
			var loggedEvent = contractInstance.UserAccountAdded();
			
                        var inter = setInterval(function() {
                        var pending =web3.eth.getBlock("pending").transactions.length;
                        if(pending==0)
                            {
                             	loggedEvent.watch(function(error, result) {
				if (error) {
					TemplateVar.set(template, 'state', {isAuthError: true});
					return;
				}
				else
				{
					if(result.args.registered) {
						TemplateVar.set(template, 'state', {isRegistered: true});}
					else
					{
						TemplateVar.set(template, 'state', {isRegistrationError: true});
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

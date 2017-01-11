var contractInstance;
var username, password;

// when the template is rendered
Template['components_login'].onRendered(function() {
});

// when the template is destroyed
Template['components_login'].onDestroyed(function() {

});

Template['components_login'].helpers({

});



Template['components_login'].events({

	"click #loginbtn": function(event, template){ 
        console.log('Login button is clicked');  
		contractInstance = web3.eth.contract(UserAccessControlContract.abi).at(useraccesscontractaddr);
		
		var transactionObject = {
		            data: UserAccessControlContract.bytecode, 
		            from: web3.eth.coinbase
	        };
		
		username = template.find("#userName").value;	
		password = template.find("#password").value;
		var loginaddress = template.find("#address").value;
			
		TemplateVar.set(template, 'state',{islogIn: true});
		contractInstance.Login.sendTransaction(username, password,loginaddress,transactionObject, function(err,txAddress){

		if(err)
			return TemplateVar.set(template, 'status', {isError: true,error:String(err)});
		else
                    {
			var loggedEvent = contractInstance.UserAuthenticated();
			
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
					if(result.args.authenticated) {
					TemplateVar.set(template, 'state', {isAuthenticated: true, username:result.args.username, 							role:result.args.roleCd });}
					else
					{
						TemplateVar.set(template, 'state', {isAuthError: true, error:result.args.username});
					}
					loggedEvent.stopWatching();
				}

				});
                               clearInterval(inter);
                            }},1000)
                    }
		});
			
		
	}

});

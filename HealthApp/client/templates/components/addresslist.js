var shareFilecontractInstance;

Template['components_addresslist'].onRendered( function(){ 
});


Template['components_addresslist'].helpers({

	'getAddressList': function(){
			
		web3.eth.defaultAccount = web3.eth.coinbase;
		shareFilecontractInstance = web3.eth.contract(UserAccessControlContract.abi).at(useraccesscontractaddr);
		var result = shareFilecontractInstance.GetAvailableAddresses.call();
		var addressArr = new Array();
		var patient,provider;
		for(var i =0;i<result[2];i++)
		{
			patient = {nodeAddress:result[0][i]};	
			addressArr.push(patient);
		}
		for(var i =0;i<result[3];i++)
		{
			provider = {nodeAddress:result[1][i]};	
			addressArr.push(provider);
		}
		return addressArr;
	}
    
    
});

Template['components_shareFile'].events({


});

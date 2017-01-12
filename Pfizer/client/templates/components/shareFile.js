var shareFilecontractInstance;


Template['components_shareFile'].onRendered( function(){        

	var instance = Template.instance();
	web3.eth.defaultAccount = web3.eth.coinbase;
           
	shareFilecontractInstance = web3.eth.contract(UserAccessControlContract.abi).at(shareFileContractAddr);
	shareFilecontractInstance.getUserFileCount.call(web3.eth.accounts[1], function(err,fileCount)
	{
		if(err)
		{
			return TemplateVar.set(instance, 'state', {isError: true, error: String(err)});
		}
		else
		{	totalfiles = fileCount;
			return TemplateVar.set(instance, 'state', {files: true, count: fileCount});
		}
	
	});	
});


Template['components_shareFile'].helpers({


	'getUploadedFiles': function(){

		web3.eth.defaultAccount = web3.eth.coinbase;
		var fileIndex = 0;
		var filecontent,fileName;
		var fileArr = new Array();
		var fileInfo;

		shareFilecontractInstance = web3.eth.contract(UserAccessControlContract.abi).at(shareFileContractAddr);
		var totalfiles = shareFilecontractInstance.getUserFileCount.call(web3.eth.accounts[1]);	

		for(var i=0; i<totalfiles;i++)
		{
		
		var result = shareFilecontractInstance.getFileDetails.call(fileIndex,web3.eth.accounts[1]);					
		fileIndex = result[0];
		filecontent = result[1];
		fileName = result[2];
		fileInfo = {index:fileIndex-1, hash:filecontent, name:fileName};
		fileArr.push(fileInfo);
		}
		return fileArr;
	},
	
	'getSharedFileCount': function(){

		web3.eth.defaultAccount = web3.eth.accounts[1];
           
		shareFilecontractInstance = web3.eth.contract(UserAccessControlContract.abi).at(shareFileContractAddr);
		var fileCount = shareFilecontractInstance.GetSharedFileCount.call(web3.eth.accounts[1]);
		return fileCount;
					
	},

	'getProviderFileCount': function(){

		web3.eth.defaultAccount = web3.eth.accounts[6];
           
		shareFilecontractInstance = web3.eth.contract(UserAccessControlContract.abi).at(shareFileContractAddr);
		var fileCount = shareFilecontractInstance.GetProviderFileCount.call(web3.eth.accounts[6]);
		return fileCount;
					
	},

	'getSharedFiles': function(){

		var FileId = 0;
		var FileIndex = 0;
		var fileName;
		var sharedProviderAddr;
		var sharedFileArr = new Array();
		var sharedFileInfo;

		web3.eth.defaultAccount = web3.eth.accounts[1];
		shareFilecontractInstance = web3.eth.contract(UserAccessControlContract.abi).at(shareFileContractAddr);
		//var sharedfiles = getSharedFileCount();
		var sharedfiles = shareFilecontractInstance.GetProviderFileCount.call(web3.eth.accounts[1]);	

		for(var i=0; i<sharedfiles;i++)
		{
		var result = shareFilecontractInstance.GetUserSharedFiles.call(FileIndex,web3.eth.accounts[1]);	
				
			FileId = result[0];
			FileIndex = result[1];
			fileName = result[2];
			sharedProviderAddr = result[3];
			sharedProvider = result[4];
			sharedFileInfo = {id:FileId, name:fileName, provider:sharedProvider, providerAddr: sharedProviderAddr};
			sharedFileArr.push(sharedFileInfo);
		}
		return sharedFileArr;
	},
	


	'getProviders': function(){
			
		web3.eth.defaultAccount = web3.eth.coinbase;
		shareFilecontractInstance = web3.eth.contract(UserAccessControlContract.abi).at(shareFileContractAddr);
		var result = shareFilecontractInstance.GetProviders.call();
		var providerArr = new Array();
		var provider;
		for(var i =0;i<result[2];i++)
		{
			provider = {name: web3.toAscii(result[0][i]).replace(/\u0000/g, ''), address:result[1][i]};	
			providerArr.push(provider);
		}
		return providerArr;
	},

	'getProviderFiles': function(){
			
		var FileId;
		var FileIndex = 0;
		var fileName,fileHash;
		var owner;
		var sharedFileArr = new Array();
		var sharedFileInfo;

		web3.eth.defaultAccount = web3.eth.coinbase;
		shareFilecontractInstance = web3.eth.contract(UserAccessControlContract.abi).at(shareFileContractAddr);
		//var sharedfiles = getSharedFileCount();
		var providerFiles = shareFilecontractInstance.GetProviderFileCount.call(web3.eth.accounts[6]);	
		console.log(providerFiles);
		for(var i=0; i<providerFiles;i++)
		{
		var result = shareFilecontractInstance.GetProviderFiles.call(web3.eth.accounts[6],FileIndex);	
				
			FileId = result[0];
			fileName = result[1];
			owner = result[2];
			fileHash = result[3];
			FileIndex = result[4]+1;
			sharedFileInfo = {id:FileId, name:fileName, owner:owner, hash: fileHash};
			sharedFileArr.push(sharedFileInfo);
		}
		return sharedFileArr;
	}
    
    
});

Template['components_shareFile'].events({

	"click #uploadFilebtn": function(event, template){ 

		var fName = template.find("#fileName").value;
		var fHash = template.find("#fileHash").value;

	        web3.eth.defaultAccount = web3.eth.accounts[1];
		shareFilecontractInstance = web3.eth.contract(UserAccessControlContract.abi).at(shareFileContractAddr);
		
		var transactionObject = {
		            data: UserAccessControlContract.bytecode, 
		            from: web3.eth.accounts[1],
				gasPrice: web3.eth.gasPrice,
            			gas: 5000000
	        };
		
		web3.eth.estimateGas(transactionObject, function(err, estimateGas){
		if(!err)
			transactionObject.gas = estimateGas * 20;
			
		TemplateVar.set(template, 'state',{inProcess: true});
		var fileEvent = shareFilecontractInstance.FileUploaded();
		shareFilecontractInstance.UploadFile.sendTransaction(fHash,fName,transactionObject, function(err,txAddress)
		{
			if(err)
				return TemplateVar.set(template, 'state', {isError: true,error:String(err)});
			else
			{
			var inter = setInterval(function() {
                        var pending =web3.eth.getBlock("pending").transactions.length;
                        if(pending==0)
                            {
                             	fileEvent.watch(function(error,result)
				{
				if (error) {
					TemplateVar.set(template, 'state', {isAuthError: true});
					return;
				}
				else if(result)
				{
					if(result.args.uploaded) 
					{
						TemplateVar.set(template, 'state', {isUploaded: true, fileName:result.args.fileName});
						return;
					}
					else
					{
						TemplateVar.set(template, 'state', {isUploadError: true});
						return;
					}
				}
				});
                               clearInterval(inter);
                            }},1000)
                    }
		});
			
		});
	},

	"click button[id ^=share]": function(event, template){ 

		var btnId = event.target.id;
		var row = event.target.closest("tr");
		var providerAddr = $(row).find("#rolelist").val();
		var index = btnId.indexOf("&$");
		var fileId = btnId.substring(5,index);
		var fileName = btnId.substring(index+2,btnId.length);

	        web3.eth.defaultAccount = web3.eth.accounts[1];
		shareFilecontractInstance = web3.eth.contract(UserAccessControlContract.abi).at(shareFileContractAddr);
		
		var transactionObject = {
		            data: UserAccessControlContract.bytecode, 
		            from: web3.eth.accounts[1],
				gasPrice: web3.eth.gasPrice,
            			gas: 5000000
	        };
		
		web3.eth.estimateGas(transactionObject, function(err, estimateGas){
		if(!err)
			transactionObject.gas = estimateGas * 20;
			
		TemplateVar.set(template, 'state',{isSharing: true});
		var fileEvent = shareFilecontractInstance.FileShared();
		shareFilecontractInstance.ShareFiles.sendTransaction(web3.eth.accounts[1],providerAddr,fileId,fileName,transactionObject, function(err,txAddress)
		{
			if(err)
				return TemplateVar.set(template, 'state', {isSharedError: true,error:String(err)});
			else
			{
			
			
                        var inter = setInterval(function() {
                        var pending =web3.eth.getBlock("pending").transactions.length;
                        if(pending==0)
                            {
                             	fileEvent.watch(function(error,result)
				{
				if (error) {
					TemplateVar.set(template, 'state', {isSharedError: true});
					return;
				}
				else if(result)
				{
					if(result.args.FileName.length>0) 
					{
						TemplateVar.set(template, 'state', {isShared: true, fileName:result.args.FileName, userName:result.args.userName, fileId:result.args.fileId });
						return;
					}
					else
					{
						TemplateVar.set(template, 'state', {isSharedError: true});
						return;
					}
				}
				});
                               clearInterval(inter);
                            }},1000)
                    }
		});
			
		});

		
	},

	"click button[id ^=revoke]": function(event, template){ 

		var btnId = event.target.id;
		var row = event.target.closest("tr");
		var firstIndex = btnId.indexOf("&$");
		var secIndex = btnId.indexOf("^$");
		var fileId = btnId.substring(6,firstIndex);
		var fileName = btnId.substring(firstIndex +2,secIndex);
		var providerAddr = $(row).find("td").eq(3).text();
		

	        web3.eth.defaultAccount = web3.eth.coinbase;
		shareFilecontractInstance = web3.eth.contract(UserAccessControlContract.abi).at(shareFileContractAddr);
		
		var transactionObject = {
		            data: UserAccessControlContract.bytecode, 
		            from: web3.eth.accounts[1],
				gasPrice: web3.eth.gasPrice,
            			gas: 5000000
	        };
		
		web3.eth.estimateGas(transactionObject, function(err, estimateGas){
		if(!err)
			transactionObject.gas = estimateGas * 20;
			
		TemplateVar.set(template, 'state',{isRevoking: true});
		var revokeEvent = shareFilecontractInstance.FileAccessRevoked();
		shareFilecontractInstance.RevokeFileAccess.sendTransaction(web3.eth.accounts[1],fileId,fileName,providerAddr,transactionObject, function(err,txAddress)
		{
			if(err)
				return TemplateVar.set(template, 'state', {isRevokeError: true,error:String(err)});
			else
			{
			
			
                        var inter = setInterval(function() {
                        var pending =web3.eth.getBlock("pending").transactions.length;
                        if(pending==0)
                            {
                             	revokeEvent.watch(function(error,result)
				{
				if (error) {
					TemplateVar.set(template, 'state', {isRevokeError: true});
					return;
				}
				else if(result)
				{
					if(result.args.fileName.length>0) 
					{
						TemplateVar.set(template, 'state', {isRevoked: true, fileName:result.args.fileName, userName:result.args.providerName});
						return;
					}
					else
					{
						TemplateVar.set(template, 'state', {isRevokeError: true});
						return;
					}
				}
				});
                               clearInterval(inter);
                            }},1000)
                    }
		});
			
		});

		
	},

	"click #CheckOwnership": function(event, template){ 

		web3.eth.defaultAccount = web3.eth.coinbase;
		shareFilecontractInstance = web3.eth.contract(UserAccessControlContract.abi).at(shareFileContractAddr);
		var result = shareFilecontractInstance.IsProvider.call(web3.eth.accounts[1]);
		alert(result);
	
	}
});

var express = require('express')
var ipfsAPI = require('ipfs-api')
var multer = require('multer')
var util = require('util')
var path=require('path')
var fs = require('fs')
var bodyparser = require ('body-parser')
var Web3 = require('web3')
var mime = require("mime");

var app = express()
var ipfs = ipfsAPI('/ip4/127.0.0.1/tcp/5001');
var router = express.Router();
var contract = require('./UserAccessControlContract.js')


process.on('uncaughtException', function (err) {
  console.error(err.stack);
  console.log("Node NOT Exiting...");
});


if (typeof web3 !== 'undefined') {
  web3 = new Web3(web3.currentProvider);
} else {
  web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8001"));
}

var useraccesscontractaddr = contract.ContractAddress();
var bytecode = contract.ByteCode();
var ABI = contract.ContractABI();

contractInstance = web3.eth.contract(ABI).at(useraccesscontractaddr);

var storage =   multer.diskStorage({
  destination: function (req, file, callback) {
    callback(null, path.join(__dirname,'./imagesPath/'));
  },
  filename: function (req, file, callback) {
    var ext = file.originalname.split('.').pop();
    callback(null,file.originalname);
  }
});

var upload = multer({ storage: storage})
var jsonparser = bodyparser.json();
app.set("json spaces",0);
app.use(express.static(__dirname+"/imagesPath"));
app.use(express.static(__dirname+"/downloads"));

app.get('/', function (req, res){
	//res.sendFile(path.join(__dirname+'/index.html'))
})

app.get('/register',function (req,res){
		var result = contractInstance.GetAvailableAddresses.call();
		var patient,provider;
    	if(result[2] ==0 && result[1][0] ==0)
    	{
    		res.sendStatus(404);
    	}
    	else
    	{
	    if(result[2] > 0)
			{
				patient = result[0][0];
			}
			if(result[3] > 0)
			{
				provider = result[1][0];
			}
    		res.json({patientAddress:patient, providerAddress:provider});
    	}
});

app.post('/register',jsonparser,function(req,res){

      var roleCd = req.body.role;
      var username = req.body.userName;
      var password = req.body.password;
      var senderAddress = req.body.address;

      var transactionObject = {
            data: bytecode, 
            from: senderAddress,
            gasPrice: web3.eth.gasPrice,
            gas: 500000
      };
        web3.eth.estimateGas(transactionObject, function(err, estimateGas){
        if(!err)
          transactionObject.gas = estimateGas * 10;
          contractInstance.Register.sendTransaction(username, password,roleCd,senderAddress,transactionObject, function(err,result){

          if(err){
            console.log(err)
            res.end(err.toString())
          }
          else
          {
            var loggedEvent = contractInstance.UserAccountAdded();
            loggedEvent.watch(function(error, result) {
            if (error) 
            {
                console.log(error.toString())
                loggedEvent.stopWatching();
                res.end(error.toString())
               
            }
            else
              {
                  if(result.args.registered) {
                    loggedEvent.stopWatching();
                    res.end();
              }
              else{
                loggedEvent.stopWatching();
                res.end("Registration Failed")
                
              }
            }
            })
          }})
        });
});

app.post('/login',jsonparser,function(req,res,next){
      console.log("Login is called")
      var username = req.body.userName;
      var password = req.body.password;
      var senderAddress = req.body.address;

      var transactionObject = {
            data: bytecode, 
            from: senderAddress,
            gasPrice: web3.eth.gasPrice,
            gas: 500000
      };
      web3.eth.estimateGas(transactionObject, function(err, estimateGas){
      if(!err)
          transactionObject.gas = estimateGas * 10;
          contractInstance.Login.sendTransaction(username, password,senderAddress,transactionObject, function(err,result){
          if(err){
            console.log(err)
            res.end(err.toString())
          }
          else
          {
            var loggedEvent = contractInstance.UserAuthenticated();
            loggedEvent.watch(function(error, result) {
            if (error) {
                console.log(error.toString())
                res.end(error.toString())

            }
            else
            {
              if(result.args.authenticated) {
                loggedEvent.stopWatching();
                res.json({role:result.args.roleCd, address:senderAddress})
                res.end()
              }
              else{
                loggedEvent.stopWatching();
                res.json({error:"Error Logging in."})
                res.end();
              }
                
            }

            })
            }

        })
      })
});

app.post('/upload',upload.single('uploadfile'),function (req,res) {
  
  var fileHash, fileName;
  fileName = req.file.originalname;
  var senderAddress = req.body.address;

  ipfs.util.addFromFs(path.join(__dirname,'imagesPath',fileName),(err, result)=>{
  if (err) {
     // res.end(err.toString())
     throw err;
  }
  fileHash = result[0].hash;
  fs.unlinkSync('./imagesPath/' + fileName);
  var transactionObject = {
            data: bytecode, 
            from: senderAddress,
            gasPrice: web3.eth.gasPrice,
            gas: 5000000
    };
  
  web3.eth.estimateGas(transactionObject, function(err, estimateGas){
  if(!err)
  {
      transactionObject.gas = estimateGas * 10;
      contractInstance.UploadFile.sendTransaction(fileHash,fileName,transactionObject, function(err,result){
      if(err){
          console.log(err)
          res.end(err.toString())
      }
      else
      {
          var loggedEvent = contractInstance.FileUploaded();
          loggedEvent.watch(function(error, result) {
          if(result.args.uploaded) {
            loggedEvent.stopWatching();
            res.end();
          }
          else{
            loggedEvent.stopWatching();
            res.json({error:"Error Uploading File"})
            res.end("Upload Failed")
          }
          });
      }

      })
  }})

  })
});

app.get('/GetFile', function(req,res){

var fileId, fileHash,filename;

fileId = req.query.id;
fileHash = req.query.hash;
filename = req.query.filename

var filePath = path.join(__dirname, 'downloads',filename);
  if(fs.existsSync(filePath))
  {
    fs.unlinkSync(filePath);
  }
 ipfs.cat(fileHash,(err, stream)=>{

 // var downloadFile;
  

  if (err) {
     console.log(err.toString());
     res.end(err.toString())
  }
  var mimetype = mime.lookup(filePath);
  var writedoc = fs.createWriteStream(filePath,{'flags':'a'});
  
  res.setHeader('Content-disposition', 'attachment; filename=' + filename);
  res.setHeader('Content-type', mimetype);
  
  stream.on('data', function (chunk) {
  //  downloadFile += chunk;
    writedoc.write(chunk);
  })

  stream.on('error', function (err) {
    fs.unlinkSync(filePath);
    console.error('Error downloading file', err)
    res.json({error:err})
  })

  stream.on('end', function () {
  var outfile = fs.createReadStream(filePath);
  outfile.pipe(res);
  })

})
});


app.get('/share/GetProviders',function(req,res)
{
	var result = contractInstance.GetProviders.call();
	var providerArr = new Array();
  var provider;
	if(result[2] >0)
	{
		for(var i =0;i<result[2];i++)
		{
			provider = {providerName: web3.toAscii(result[0][i]).replace(/\u0000/g, ''), providerAddress:result[1][i]};	
			providerArr.push(provider);
		}
		res.json({providers: providerArr});
	}
	else
  {
    res.json({error:"No providers registered"})
		res.end();
  }
});

app.get('/share/GetAllFiles',jsonparser,function(req,res)
{
	var address = req.query.address;
	var fileIndex = 0;
	var sharedFileIndex = 0;
	var filecontent,fileName;
	var fileArr = new Array();
	var fileInfo;
	var sharedProviderAddr;
	var sharedFileArr = new Array();
	var FileId = 0;
	var sharedFileInfo;
	
	var uploadedFileCount = contractInstance.getUserFileCount.call(address);
	
	for(var i=0; i<uploadedFileCount;i++)
	{
		var uploadedFiles = contractInstance.getFileDetails.call(fileIndex,address);					
		fileIndex = uploadedFiles[0];
		filecontent = uploadedFiles[1];
		fileName = uploadedFiles[2];
		fileInfo = {id:fileIndex-1, hash:filecontent, name:fileName, provider:"", providerAddress:""};
		fileArr.push(fileInfo);
	}
	
	var sharedFileCount = contractInstance.GetSharedFileCount.call(address);
	for(var i=0; i<sharedFileCount;i++)
	{
		var sharedFiles = contractInstance.GetUserSharedFiles.call(sharedFileIndex,address);					
		FileId = sharedFiles[0];
		shareFileIndex = sharedFiles[1];
		fileName = sharedFiles[2];
		sharedProviderAddr = sharedFiles[3];
		sharedProvider = sharedFiles[4];
		sharedFileInfo = {id:FileId, name:fileName, provider:sharedProvider, providerAddr: sharedProviderAddr};
		sharedFileArr.push(sharedFileInfo);	
	}

	for(var count=0;count<fileArr.length;count++)
	{
		for(var scount=0;scount<sharedFileArr.length;scount++)
		{
			if(fileArr[count].id==sharedFileArr[scount].id && fileArr[count].name==sharedFileArr[scount].name)
			{
				fileArr[count].providerAddress = sharedFileArr[scount].providerAddr;
				fileArr[count].provider = sharedFileArr[scount].provider;
			}
		}
	}

	res.json({UploadedFiles:fileArr});
	
});

app.get('/Provider/GetFiles',jsonparser,function(req,res)
{
    var FileId;
    var FileIndex = 0;
    var fileName,fileHash;
    var owner;
    var sharedFileArr = new Array();
    var sharedFileInfo;

    var address = req.query.address;

    var providerFiles = contractInstance.GetProviderFileCount.call(address);  
    for(var i=0; i<providerFiles;i++)
    {
      var result = contractInstance.GetProviderFiles.call(address,FileIndex); 
      FileId = result[0];
      fileName = result[1];
      owner = result[2];
      fileHash = result[3];
      FileIndex = result[4]+1;
      sharedFileInfo = {id:FileId, name:fileName, owner:owner, hash: fileHash};
      sharedFileArr.push(sharedFileInfo);
    }
    res.json({Files:sharedFileArr});
});

app.get('/share/GetRevokedFiles',jsonparser,function(req,res)
{
    var FileId;
    var FileIndex = 0;
    var fileName;
    var providerName;
    var revokedFileArr = new Array();
    var revokedFileInfo;

    var address = req.query.address;

    var uploadedFiles = contractInstance.getUserFileCount.call(address);  
    for(var i=0; i<uploadedFiles;i++)
    {
      var result = contractInstance.GetUserRevokedFiles.call(FileIndex,address); 
      FileId = result[0];
      FileIndex = result[1];
      fileName = result[2];
      providerName = result[3];
    
      revokedFileInfo = {id:FileId, name:fileName, provider:providerName};
      revokedFileArr.push(revokedFileInfo);
    }
    res.json({RevokedFiles:revokedFileArr});
});

app.post('/share',jsonparser,function(req,res){

      var fileName = req.body.fileName;
      var ownerAddress = req.body.address;
      var providerAddress = req.body.providerAddress;
      var fileId = req.body.fileId;
      
      var transactionObject = {
            data: bytecode,
            from: ownerAddress,
            gasPrice: web3.eth.gasPrice,
            gas: 5000000
      };

      web3.eth.estimateGas(transactionObject, function(err, estimateGas){
        if(!err)
          transactionObject.gas = estimateGas * 20;
          contractInstance.ShareFiles.sendTransaction(ownerAddress,providerAddress,fileId,fileName,transactionObject, function(err,result){

          if(err){
            console.log(err)
            res.end(err.toString())
          }
          else
          {
            var loggedEvent = contractInstance.FileShared();
            loggedEvent.watch(function(error, result) {
            if (error) {
              console.log(error.toString())
              res.end(error.toString())
            }
            else
            {
              if(result.args.FileName.length > 0) {
                loggedEvent.stopWatching();
                res.end()
              }
              else{
                loggedEvent.stopWatching();
                res.end()
              }
              
            }

            });
          }

        })
      })
});

app.post('/delete',jsonparser,function(req,res){

      var ownerAddress = req.body.address;
      var fileId = req.body.fileId;
      
      var transactionObject = {
            data: bytecode,
            from: ownerAddress,
            gasPrice: web3.eth.gasPrice,
            gas: 5000000
      };

      web3.eth.estimateGas(transactionObject, function(err, estimateGas){
        if(!err)
          transactionObject.gas = estimateGas * 20;
          
          contractInstance.RemoveFile.sendTransaction(fileId,ownerAddress,transactionObject, function(err,result){

          if(err){
            console.log(err)
             res.json({error:err})
          }
          else
          {
            var loggedEvent = contractInstance.FileDeleted();  
            loggedEvent.watch(function(error, result) {
            if (error) {
              console.log(error.toString())
              res.json({error:error})
            }
            else
            {
              if(result.args.deleted) {
                loggedEvent.stopWatching();
                console.log("deleted")
                res.end();
              }
              else{
                loggedEvent.stopWatching();
                console.log("error deleting")
                res.json({error:"Error Deleting file."})
              }
              
            }

            });
          }

        })
      })
});


app.post('/revoke',jsonparser,function(req,res){

      var fileName = req.body.fileName;
      var ownerAddress = req.body.address;
      var providerAddress = req.body.providerAddress;
      var fileId = req.body.fileId;
      
      var transactionObject = {
            data: bytecode,
            from: ownerAddress,
            gasPrice: web3.eth.gasPrice,
            gas: 5000000
      };

      web3.eth.estimateGas(transactionObject, function(err, estimateGas){
        if(!err)
          transactionObject.gas = estimateGas * 20;
      	
        contractInstance.RevokeFileAccess.sendTransaction(ownerAddress,fileId,fileName,providerAddress,transactionObject, function(err,result){

          if(err){
            console.log(err)
            res.json({error:err})
            res.end(err.toString())
          }
          else
          {
            var loggedEvent = contractInstance.FileAccessRevoked();
            loggedEvent.watch(function(error, result) {
              if (error) {
                console.log(error.toString())
                res.json({error:err})
                res.end();
              }
              else
              {
                if(result.args.fileName.length > 0) {
                  loggedEvent.stopWatching();
                  res.end()
                }
                else{
                  loggedEvent.stopWatching();
                  res.json({error:"Error revoking file access."})
                  res.end();
                }
                
              }

              });
        }

        })
      })
});

app.listen(7000, function () {

console.log('Node server started!')
})
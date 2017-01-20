pragma solidity ^0.4.0;
contract UserAccessControlContract {

	enum Roles {None,Admin,Participant,Provider} 
	
	struct UserAccount{
		address userAddress;
		string userName;
		string password;
		Roles roleCode;
	}

	struct FileDetails
	{
		string fileHash;
		string fileName;
		address userAddress;	
	}
	
	struct SharedFile
	{
	    uint FileId; //mapping key from uploadedFiles Mapping
	    address ownerAddress;
	    address sharedUserAddress;
	    bool sharedFlg;
	}

	struct RoleAddress
	{
		address nodeAddress;
		Roles roleCode;
		bool addressUsed;
	}

   	event FileUploaded (string fileName,bool uploaded);
	event UserAccountAdded (bool registered);
	event UserAuthenticated(bool authenticated,string username, uint roleCd, address userAddress);
	event FileShared(string FileName, string userName, uint fileId);
	event FileAccessRevoked(string fileName, string providerName);
	event FileDeleted(bool deleted);
	event AddressAdded(bool added);

	uint public numUsers;
	uint public numFiles;
	uint public sharedFileIndex;
	uint public addressCount;
	mapping (uint => FileDetails) public uploadedFiles;
	mapping (address => UserAccount) public users;
	mapping (uint => UserAccount) public useraccounts;
	mapping (uint => SharedFile) public sharedFiles;
	mapping (uint => RoleAddress) public availAddresses;


	Roles public role;

	function UserAccessControlContract(string username, string password) {
		users[msg.sender] = UserAccount(msg.sender, username, password, Roles.Admin);
		useraccounts[numUsers] = users[msg.sender];
		numUsers++;
	}

	function ResetContract(){
		
        //to clear a mapping hashtable in solidity
        for(uint i=0;i<numFiles;i++)
		{
		    delete uploadedFiles[i];	
		}
		
		for(i=0;i<numUsers;i++)
		{
		    delete users[useraccounts[i].userAddress];
		    delete useraccounts[i];
		}
        
        for(i=0;i<sharedFileIndex;i++)
		{
		    delete sharedFiles[i];	
		}
        
        for(i=0;i<addressCount;i++)
		{
		    delete availAddresses[i];	
		}
		
		numUsers=0;
		numFiles=0;
		sharedFileIndex=0;
		addressCount=0;
	
	
		users[0x922debc000dd9303a3e47be7127498329f598029] = UserAccount(0x922debc000dd9303a3e47be7127498329f598029, "admin", "admin", Roles.Admin);
		useraccounts[numUsers] = users[0x922debc000dd9303a3e47be7127498329f598029];
		numUsers++;

		AddAddress(0x9130b6ae79c363f101f419811433ca5dbba7ee7b,Roles.Participant);
		AddAddress(0xb490511d508990feb70513f9f39d2280c41699b5,Roles.Participant);
		AddAddress(0x81adbc2fb0ea19ba61e93dc5ef9864c0497ea2b1,Roles.Participant);
		AddAddress(0x39bddda10dc121d7cc7ff97186b6f0d382206eac,Roles.Participant);
		AddAddress(0x3b5a64d9886e4df7fe99b3289032378895fb6bf7,Roles.Participant);

		AddAddress(0x4945d9c2e5ce6f0ced789c08602acad3071e621b,Roles.Provider);
		AddAddress(0x2c58aa399dd93656da88adf3f8dc52ce99d45a58,Roles.Provider);
		AddAddress(0x0fe0ac23d61d0d5e1b5ce29d79b277f455bfa3e2,Roles.Provider);
		AddAddress(0x2545ff3db992f9cb830a6c634e50a111cff17662,Roles.Provider);
		AddAddress(0x13141b3286030e0e6b218a5acbfb081342c36562,Roles.Provider);

	}

	function AddAddress(address nodeAddress, Roles RoleCd) returns (bool){

		for(uint i=0;i<addressCount;i++)
		{
			if(availAddresses[i].nodeAddress==nodeAddress)
			{
				AddressAdded(false);
				return false;
			}
		}
		availAddresses[addressCount] = RoleAddress(nodeAddress,RoleCd,false);
		addressCount++;
		AddressAdded(true);
		return true;
	}

	function GetAvailableAddresses() public returns (address[50] patientAddress, address[50] providerAddress, uint patAddressCount, uint providerAddressCount)
	{
		patAddressCount = 0; 
		providerAddressCount = 0;
		for(uint i=0;i<addressCount;i++)
		{
			if(!availAddresses[i].addressUsed)
			{
				if(availAddresses[i].roleCode == Roles.Participant)
				{
					patientAddress[patAddressCount] = availAddresses[i].nodeAddress;
					patAddressCount++;
				}
				else if(availAddresses[i].roleCode == Roles.Provider)
				{
					providerAddress[providerAddressCount] = availAddresses[i].nodeAddress;
					providerAddressCount++;																								
				}
			}
		}
	}	
	function Register(string username, string password, Roles roleCode, address nodeAddress) public {
	
		if(!CheckIfUserExists(nodeAddress,username))
		{	
			users[nodeAddress] = UserAccount(nodeAddress, username, password, roleCode);
			useraccounts[numUsers] = users[nodeAddress];
           	numUsers++;
			if(users[nodeAddress].userAddress == nodeAddress) 
			{
				for(uint i=0;i<addressCount;i++)
				{
					if(availAddresses[i].nodeAddress==nodeAddress)
					{
						availAddresses[i] = RoleAddress(nodeAddress, roleCode, true);
						UserAccountAdded(true);	
						return;	
					}
				}
			}
			else
			{
				UserAccountAdded(false);	
				return;	
			}
		}
		else
		{
			UserAccountAdded(false);
			return;
		}
	}

	function RemoveFile(uint FileId, address OwnerAddress) public returns (bool)
	{
	    FileDetails fileToDelete = uploadedFiles[FileId];
		bool deleted = false;
		address shareOwner;

		if(fileToDelete.userAddress==OwnerAddress)
        {
        	for(uint fileIndex = 0; fileIndex<sharedFileIndex;fileIndex++)
			{
				shareOwner = sharedFiles[fileIndex].ownerAddress;
				if(OwnerAddress == shareOwner && sharedFiles[fileIndex].FileId==FileId)
				{
					if(sharedFiles[fileIndex].sharedFlg)
					{
						FileDeleted (deleted);
						return deleted;
					}
					else
					{
						delete sharedFiles[fileIndex];
						deleted = true;
						--sharedFileIndex;
						FileDeleted(deleted);
						return deleted;
					}
				}
			}
            delete uploadedFiles[FileId];
            --numFiles;
            deleted = true;
		    FileDeleted(deleted);
		    return deleted;
		}   
		else
		{
			FileDeleted(deleted);
			return deleted;
		}
	}


	function CheckIfUserExists(address userAddr, string username) internal returns (bool) {

		UserAccount user = users[userAddr];
		if(bytes(user.userName).length > 0 && stringsEqual(user.userName, username))
			return true;
		else
			return false;
	}

	function GetProviders() public returns(bytes32[50] providers, address[50] provideraddress, uint)
	{
	    uint providerCount;
	    for(uint count=0; count < numUsers; count++)
	    {
	        UserAccount user = useraccounts[count];
	        if(user.roleCode==Roles.Provider)
	        {
	            
	            providers[providerCount] = stringToBytes32(user.userName);
	            provideraddress[providerCount] = user.userAddress;
	            providerCount++;
	        }
	        
	    }
		return (providers, provideraddress,providerCount);
	    
	}

   	function Login(string username, string password, address loginAddress) public {
		UserAccount user = users[loginAddress];

		string userlogin = user.userName;
		string userpass = user.password;
		if(stringsEqual (userlogin, username) && stringsEqual(userpass, password))
		{
		    role = user.roleCode;
		    UserAuthenticated(true,userlogin,uint(role),user.userAddress);
			return;
		}
		else
		{
			UserAuthenticated(false,username,uint(Roles.None),loginAddress);	
			return;	
		}
	
	}
	
	function UploadFile(string fHash, string fileName) public
	{
		uploadedFiles[numFiles] = FileDetails(fHash, fileName, msg.sender);
		numFiles++;
		bool uploaded = true;
		FileUploaded (fileName, uploaded);
	}
		
	function getUserFileCount(address sender) public returns (uint fileCount)
	{
		address OwnerAddress;
		for(uint fileIndex = 0; fileIndex<numFiles;fileIndex++)
		{
			OwnerAddress = uploadedFiles[fileIndex].userAddress;
			if(OwnerAddress == sender)
			{
				fileCount++;
			}
		}
		return fileCount;
	}

	function getFileDetails(uint fileNo, address sender) public returns (uint fileIndex, string contentHash, string filename)
	{
		address OwnerAddress;
		for(uint i = fileNo; i<numFiles;i++)
		{
			OwnerAddress = uploadedFiles[i].userAddress;
			if(OwnerAddress == sender)
			{
				contentHash = uploadedFiles[i].fileHash;
				filename = uploadedFiles[i].fileName;
				fileIndex = i +1;
				return (fileIndex, contentHash,filename);
			}
		}
		throw;
	}
	
	function ShareFiles(address ownerAddress, address providerAddress, uint FileId, string FileName) public returns(bool)
	{
	    	if(CheckOwnership(FileId, ownerAddress) && IsProvider(providerAddress))
	 	    {
		       	UserAccount provider = users[providerAddress]; 
		       	sharedFiles[sharedFileIndex] = SharedFile(FileId, ownerAddress, providerAddress,true);
				sharedFileIndex++;
		       	FileShared(FileName,provider.userName, FileId);
		       	return true;
	    	}
		    else throw;
	}

	function GetSharedFileCount(address owner) public returns (uint sharedFileCount)
	{
		address OwnerAddress;
		for(uint fileIndex = 0; fileIndex<sharedFileIndex;fileIndex++)
		{
			OwnerAddress = sharedFiles[fileIndex].ownerAddress;
			if(OwnerAddress == owner && sharedFiles[fileIndex].sharedFlg)
			{
				sharedFileCount++;
			}
		}
		return sharedFileCount;
	}


	function GetUserSharedFiles(uint fileNo,address sender) public returns (uint fileId, uint fileIndex, string fileName, address provider, string providerName)
	{
		address OwnerAddress;
		for(uint i = fileNo; i<sharedFileIndex;i++)
		{
			OwnerAddress = sharedFiles[i].ownerAddress;
			if(OwnerAddress == sender && sharedFiles[i].sharedFlg)
			{
				fileId = sharedFiles[i].FileId;
				fileName = uploadedFiles[sharedFiles[i].FileId].fileName;
				provider = sharedFiles[i].sharedUserAddress;
				providerName = users[sharedFiles[i].sharedUserAddress].userName;
				fileIndex = i +1;
				return (fileId,fileIndex, fileName,provider,providerName);
			}
		}
		throw;
	}
	
	function RevokeFileAccess(address owner, uint fileId, string fileName, address providerAddress) public returns (string, uint, string providerName)
	{
	        if(CheckOwnership(fileId, owner) && IsProvider(providerAddress))
	 	    {
		       	for(uint i = 0; i<sharedFileIndex;i++)
        		{
        			SharedFile file = sharedFiles[i];
        			if((file.ownerAddress == owner) && (file.FileId == fileId) && (file.sharedUserAddress==providerAddress) && file.sharedFlg)
        			{
        				sharedFiles[i] = SharedFile(fileId,owner,providerAddress, false);
        				//delete sharedFiles[i];
        				providerName = users[providerAddress].userName;
						FileAccessRevoked(fileName, providerName);
        				return (fileName, fileId,providerName);
        			}
        		}
	    	}
		    throw;
	}

	function GetUserRevokedFiles(uint fileNo,address owner) public returns (uint fileId, uint fileIndex, string fileName,string providerName)
	{
		address OwnerAddress;
		for(uint i = fileNo; i<sharedFileIndex;i++)
		{
			OwnerAddress = sharedFiles[i].ownerAddress;
			if(OwnerAddress == owner && !sharedFiles[i].sharedFlg)
			{
				fileId = sharedFiles[i].FileId;
				fileName = uploadedFiles[sharedFiles[i].FileId].fileName;
				providerName = users[sharedFiles[i].sharedUserAddress].userName;
				fileIndex = i +1;
				return (fileId,fileIndex,fileName,providerName);
			}
		}
		throw;
	}
	
	function GetProviderFileCount(address provider) public returns (uint providerFileCount)
	{
		address providerAddress;
		for(uint fileIndex = 0; fileIndex<sharedFileIndex;fileIndex++)
		{
			providerAddress = sharedFiles[fileIndex].sharedUserAddress;
			if(providerAddress == provider && sharedFiles[fileIndex].sharedFlg)
			{
				providerFileCount++;
			}
		}
		return providerFileCount;
	}
	
	function GetProviderFiles(address provider, uint nextIndex ) returns (uint fileId, string fileName,string patientName,string FileHash, uint currentIndex)
	{
	    address ProviderAddress;
	    for(uint fileIndex = nextIndex; fileIndex<sharedFileIndex;fileIndex++)
		{
			ProviderAddress = sharedFiles[fileIndex].sharedUserAddress;
			if(ProviderAddress == provider && sharedFiles[fileIndex].sharedFlg)
			{
				FileDetails file = uploadedFiles[sharedFiles[fileIndex].FileId];
				if(file.userAddress==sharedFiles[fileIndex].ownerAddress)
				{
				    currentIndex = fileIndex;
				    return(sharedFiles[fileIndex].FileId,file.fileName,users[file.userAddress].userName,file.fileHash,currentIndex);
				}
			}
		}
		throw;
	    
	}
	
	function CheckOwnership(uint FileId, address ownerAddress) public returns (bool)
	{
	    UserAccount owner = users[ownerAddress];
	    if(bytes(owner.userName).length >0 && owner.roleCode==Roles.Participant)
	    {
	        if(uploadedFiles[FileId].userAddress == ownerAddress)
	        {
	            return (true);
	        }
	        else
	            return (false);
	    }
	    else return (false);
	}
	
	function IsProvider(address providerAddress) public returns (bool)
	{
	    UserAccount provider = users[providerAddress];
	    if(bytes(provider.userName).length >0 && provider.roleCode==Roles.Provider)
	    {
	        return true;
	    }
	    else return false;
	}

	function stringToBytes32(string memory source) returns (bytes32 result) {
		assembly {
		    result := mload(add(source, 32))
		}
    	}

	function compareString(string memory _a, string memory _b) internal returns (bool) {
		bytes memory a = bytes(_a);
		bytes memory b = bytes(_b);
		if (a.length != b.length)
			return false;
		for (uint i = 0; i < a.length; i ++)
			if (a[i] != b[i])
				return false;
		return true;
	}
	
	function stringsEqual(string storage _a, string memory _b) internal returns (bool) {
		bytes storage a = bytes(_a);
		bytes memory b = bytes(_b);
		if (a.length != b.length)
			return false;
		for (uint i = 0; i < a.length; i ++)
			if (a[i] != b[i])
				return false;
		return true;
	}
	
    function() {
        throw;
    }
}
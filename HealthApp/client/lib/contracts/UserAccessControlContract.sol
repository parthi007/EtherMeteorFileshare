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
	event AddressAdded(bool added);

	uint numUsers;
	uint numFiles;
	uint sharedFileIndex;
	uint addressCount;
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
        				delete sharedFiles[i];
        				providerName = users[providerAddress].userName;
						FileAccessRevoked(fileName, providerName);
        				return (fileName, fileId,providerName);
        			}
        		}
	    	}
		    else throw;
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
	    if(bytes(owner.userName).length >0) //&& owner.roleCode==Roles.Participant)
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


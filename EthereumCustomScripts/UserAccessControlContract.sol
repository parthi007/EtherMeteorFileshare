pragma solidity ^0.4.0;
contract UserAccessControlContract {

	enum Roles {None,Admin,Participant,Provider,Auditor} 
	
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
		bool isDeleted;	
	}
	
	struct SharedFile
	{
	    uint FileId; //mapping key from uploadedFiles Mapping
	    address ownerAddress;
	    address sharedUserAddress;
	    bool sharedFlg;
	    string timeStamp;
	}

	struct RoleAddress
	{
		address nodeAddress;
		Roles roleCode;
		bool addressUsed;
	}

   	event FileUploaded (string fileName,bool uploaded,address indexed participantAddress, string participantName);
   	event FileDownloaded(string fileName, uint fileId);
	event UserAccountAdded (bool registered);
	event UserAuthenticated(bool authenticated,string username, uint roleCd,address indexed userAddress);
	event FileShared(string FileName, string userName, uint fileId, address indexed participantAddress, address indexed providerAddress);
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
	
	modifier require(bool _condition) {
        if (!_condition) throw;
        _;
    }

    modifier onlyAuditor() {
        if (!IsAuditor(msg.sender)) throw;
        _;
    }

    modifier onlyProvider() {
        if (!IsProvider(msg.sender)) throw;
        _;
    }

    modifier onlyParticipant() {
        if (!IsParticipant(msg.sender)) throw;
        _;
    }


	function ResetContract(){
		
		numUsers=0;
		numFiles=0;
		sharedFileIndex=0;
		addressCount=0;
	
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

	function getFileDetailsForAuditor(uint fileNo, address sender) public 
	onlyAuditor
	returns (string uploadedFileDetails)
	{
		var uploadedFileDetail =  "";
		 
		for(uint i = 0; i<numFiles;i++)
		{
			var OwnerAddress = uploadedFiles[i].userAddress;
			var contentHash = uploadedFiles[i].fileHash;
			var filename = uploadedFiles[i].fileName;			
			uploadedFileDetail =  strConcat(toString(OwnerAddress), filename, contentHash, "||", "");
		}

		return uploadedFileDetail;
	}



	function GetAvailableAddresses() public returns (address[200] patientAddress, address[200] providerAddress, uint patAddressCount, uint providerAddressCount)
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



	function RemoveFile(uint FileId, address OwnerAddress) public
	onlyParticipant
	returns (bool)
	{

		bool deleted = false;

	    FileDetails fileToDelete = uploadedFiles[FileId];
		
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
						sharedFiles[fileIndex].ownerAddress=0x0000000000000000000000000000000000000000;
						sharedFiles[fileIndex].sharedUserAddress=0x0000000000000000000000000000000000000000;
					}
				}
			}
            uploadedFiles[FileId].userAddress=0x0000000000000000000000000000000000000000;            
            uploadedFiles[FileId].isDeleted = true;
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

	function GetProviders() public returns(bytes32[200] providers, address[200] provideraddress, uint)
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
	onlyParticipant
	{

		uploadedFiles[numFiles] = FileDetails(fHash, fileName, msg.sender,false);
		numFiles++;
		bool uploaded = true;
		string userName = users[msg.sender].userName;
		FileUploaded (fileName, uploaded, msg.sender, userName);
	}

	function DownloadFile(string fileName, uint fileId) public
	{		
		FileDownloaded (fileName, fileId);
	}
		
	function getUserFileCount(address sender) public returns (uint fileCount)
	{
		address OwnerAddress;
		for(uint fileIndex = 0; fileIndex<numFiles;fileIndex++)
		{
			OwnerAddress = uploadedFiles[fileIndex].userAddress;
			if(OwnerAddress == sender && !uploadedFiles[fileIndex].isDeleted)
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
			if(OwnerAddress == sender && !uploadedFiles[i].isDeleted)
			{
				contentHash = uploadedFiles[i].fileHash;
				filename = uploadedFiles[i].fileName;
				fileIndex = i +1;
				return (fileIndex, contentHash,filename);
			}
		}
		throw;
	}
	
	function ShareFiles(address ownerAddress, address providerAddress, uint FileId, string FileName, string timeStamp) public
	onlyParticipant
	returns(bool)
	{
	    	if(CheckOwnership(FileId, ownerAddress) && IsProvider(providerAddress))
	 	    {
		       	UserAccount provider = users[providerAddress]; 
		       	sharedFiles[sharedFileIndex] = SharedFile(FileId, ownerAddress, providerAddress,true, timeStamp);
				sharedFileIndex++;
		       	FileShared(FileName,provider.userName, FileId, ownerAddress, providerAddress);
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


	function GetUserSharedFiles(uint fileNo,address sender) public returns (uint fileId, uint fileIndex, string fileName, address provider, string providerName, string timeStamp)
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
				timeStamp = sharedFiles[i].timeStamp;
				fileIndex = i +1;
				return (fileId,fileIndex, fileName,provider,providerName, timeStamp);
			}
		}
		throw;
	}
	
	function RevokeFileAccess(address owner, uint fileId, string fileName, address providerAddress) public 
	onlyParticipant
	returns (string, uint, string providerName)
	{
	        if(CheckOwnership(fileId, owner) && IsProvider(providerAddress))
	 	    {
		       	for(uint i = 0; i<sharedFileIndex;i++)
        		{
        			SharedFile file = sharedFiles[i];
        			if((file.ownerAddress == owner) && (file.FileId == fileId) && (file.sharedUserAddress==providerAddress) && file.sharedFlg)
        			{
        				sharedFiles[i] = SharedFile(fileId,owner,providerAddress, false,"");
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
	
	function GetProviderFiles(address provider, uint nextIndex ) returns (uint fileId, string fileName,string patientName,string FileHash, uint currentIndex, string timeStamp)
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
				    return(sharedFiles[fileIndex].FileId,file.fileName,users[file.userAddress].userName,file.fileHash,currentIndex, sharedFiles[fileIndex].timeStamp);
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
	        if((uploadedFiles[FileId].userAddress == ownerAddress) && !uploadedFiles[FileId].isDeleted)
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

	
	function IsParticipant(address userAddress) public returns (bool)
	{
	    UserAccount participant = users[userAddress];
	    if(bytes(participant.userName).length >0 && participant.roleCode==Roles.Participant)
	    {
	        return true;
	    }
	    else return false;
	}


	function IsAuditor(address auditorAddress) public returns (bool)
	{
	    UserAccount auditor = users[auditorAddress];
	    if(bytes(auditor.userName).length >0 && auditor.roleCode==Roles.Auditor)
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
	
	//utiltiy function to convert address to string
	function toString(address x) returns (string) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++)
            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        return string(b);
    }
    
    function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }
	
    function() {
        throw;
    }
}
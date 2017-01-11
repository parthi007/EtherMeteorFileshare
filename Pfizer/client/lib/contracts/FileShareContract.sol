contract FileShareContract
{
	struct FileDetails 
	{
		string fileHash;
		string fileName;
		string userName;	
		string allowedUser;
	}


event FileUploaded (string fileName,bool uploaded);
	uint numFiles;
	mapping (uint => FileDetails) sharedFiles;
	mapping (address => FileDetails) shar;

function UploadFile(string fHash, string file, string user)
{
	numFiles = numFiles++;	
	shar[msg.sender] = FileDetails(fHash, file, user, user);
	bool uploaded = true;
	FileUploaded (file, uploaded);
//	return (file, uploaded);

}

function getFileDetails(address sender) returns (string)
{
	return shar[msg.sender].fileHash;
}

function ProvideAccess(string fileHash, string fileName, string userName, string permitUser) returns (bool)
{
	
	for (uint i=0; i<numFiles; i++)
	{
		FileDetails memory file = sharedFiles[i];
		if(compareString(file.fileName, fileName) && compareString(file.userName, userName))
		{
			file.allowedUser = permitUser;
			return true;			
		}
	}
	return false;
}

function RevokeAccess(string fileHash, string fileName, string userName, string permitUser) returns (bool)
{
	
	for (uint i=0; i<numFiles; i++)
	{
		FileDetails memory file = sharedFiles[i];
		if(compareString(file.fileName, fileName) && compareString(file.userName, userName) && compareString(file.allowedUser,permitUser))
		{
			file.allowedUser="";
			return true;			
		}
	}
	return false;
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
    function() {
        throw;
    }
}

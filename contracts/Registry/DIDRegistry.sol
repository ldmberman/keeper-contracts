pragma solidity ^0.4.24;

/**
@title Ocean DID Registry Contract
@author Team: Ahmed Ali, Aitor Argomaniz
*/

contract DIDRegistry {

    struct DID {
        bool status;
        string did;
        string url;
    }

    address private owner;
    mapping (address => DID) DIDs;

    event DIDRegistered(string _DID, string _docUrl, address _owner, string _status);
    event DIDUpdated(string _DID, string _docUrl, address _owner, string _status);
    event DIDDeleted(address _owner, string did , string _status);
    event NotExist(string _data);

    constructor () public {
        assert(msg.sender!=address(0));
        owner = msg.sender;
    }

    function registerDID(string _DID, string _docUrl) public {
        assert(msg.sender!=address(0));
        require(!DIDs[msg.sender].status);
        DIDs[msg.sender] = DID(true, _DID, _docUrl);
        emit DIDRegistered(_DID,  _docUrl, msg.sender, "Registered");
    }

    function updateDIDReference(string _DID) public {
        if (DIDs[msg.sender].status == true) {
            DIDs[msg.sender].did = _DID;
            emit DIDUpdated(_DID, DIDs[msg.sender].url, msg.sender, "Updated");
         }else {
            emit NotExist(_DID);
         }
    }

    function updateUrlReference(string _docUrl) public {
        if (DIDs[msg.sender].status == true) {
            DIDs[msg.sender].url = _docUrl;
            emit DIDUpdated(DIDs[msg.sender].did, DIDs[msg.sender].url, msg.sender, "Updated");
        }else{
            emit NotExist(_docUrl);
        }
    }

    function unregisterDID() public returns (bool){
        if (DIDs[msg.sender].status == true){
            emit DIDDeleted(msg.sender, DIDs[msg.sender].did , "Deleted");
            delete DIDs[msg.sender];
            return true;
        }
        return false;
    }
}

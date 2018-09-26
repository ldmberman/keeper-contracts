pragma solidity ^0.4.24;

/**
@title Ocean DID Registry Contract
@author Team: Ahmed Ali
*/

contract DIDRegistry {

    struct DID {
        address owner;
        string docUrl;
    }

    address private owner;
    mapping (string => DID) DIDs;

    event DIDRegistered(string indexed _DID, string indexed _docUrl, address indexed _owner);
    event DIDUpdated(string indexed _DID, string indexed _docUrl, address indexed _owner);

    constructor () public {
        assert(msg.sender!=address(0));
        owner = msg.sender;
    }

    function registerDID(string _DID, string _docUrl) public returns (bool) {
        assert(msg.sender!=address(0));
        if(msg.sender == DIDs[_DID].owner){
            DIDs[_DID].docUrl = _docUrl;
            emit DIDUpdated(_DID, _docUrl, msg.sender);
        }else{
            DID memory newDID = DID(msg.sender, _docUrl);
            DIDs[_DID] = newDID;
            emit DIDRegistered(_DID, _docUrl, msg.sender);
        }
        return true;
    }
}

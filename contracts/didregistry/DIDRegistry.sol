pragma solidity 0.4.25;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract DIDRegistry is Ownable {
    enum DocumentType { Asset }

    struct Identity {
        address owner;
        string did;
        DocumentType _type;
    }

    // FIXME if we index the string field (did), there gonna be problems reading it
    // via web3js - https://github.com/ethereum/web3.js/issues/434.
    event DIDAttributeRegistered(
        string did,
        address indexed owner,
        DocumentType _type,
        bytes32 indexed key,
        string value,
        uint updatedAt
    );

    Identity me;

    constructor(string _did, DocumentType _type) Ownable() public {
        me = Identity({owner: msg.sender, did: _did, _type: _type});
    }

    function registerAttribute(bytes32 _key, string _value) public onlyOwner {
        emit DIDAttributeRegistered(me.did, me.owner, me._type, _key, _value, block.number);
    }
}

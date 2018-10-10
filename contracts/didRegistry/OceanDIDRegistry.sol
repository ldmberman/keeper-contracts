pragma solidity 0.4.25;

/**
@title Ocean Protocol Authorization Contract
@author Team: Fang Gong, Ahmed Ali, Sebastian Gerske, Samer Sallam
*/
contract OceanDIDRegistry {

    // ============
    // DATA STRUCTURES:
    // ============

    struct DIDRegistry {
        bytes32 did;
        address owner;  // owner of the DID entries
        uint32 sequence;
    }

    mapping(bytes32 => DIDRegistry) public mDIDRegistry;           // mapping DID hash to DID registry struct


    // ============
    // modifier:
    // ============
    modifier validAddress(address sender) {
        require(sender != address(0x0), 'Sender address is 0x0.');
        _;
    }


    // ============
    // EVENTS:
    // ============
    /* solium-disable-next-line max-len */
    event DIDRegistered(bytes32 _did, address indexed _owner);
    event DDOUpdated(bytes32 indexed _did, uint32 sequence, string _ddo);

    /**
    * @dev OceanDIDRegistry Constructor
    * Runs only on initial contract creation.
    */
    constructor() public {
    }

    /**
    * @dev provider register the new DID
    * @param _did an integer identifier hash of the DID
    * @return valid Boolean indication of registration of new asset
    */
    function register(bytes32 _did) public validAddress(msg.sender) returns (bool success) {
        require(mDIDRegistry[_did].owner == address(0), 'Owner address is not 0x0.');
        mDIDRegistry[_did] = DIDRegistry(_did, msg.sender, 0);

        emit DIDRegistered(_did, msg.sender);
        return true;
    }

    /**
    * @dev add a new DDO entry for a DID
    * @param _did the integer identifier of hash of the DID
    * @param _ddo the string to the DDO to record as an event on the block chain
    * @return True
    */
    function updateDDO(bytes32 _did, string _ddo) public validAddress(msg.sender) returns (bool success) {
        require(mDIDRegistry[_did].owner == msg.sender, 'Not the owner address of this DID');
        mDIDRegistry[_did].sequence ++;
        emit DDOUpdated(_did, mDIDRegistry[_did].sequence, _ddo);
        return true;
    }

}

// solium-disable security/no-block-members, emit

pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import '../tcr/OceanRegistry.sol';
import '../plcrvoting/PLCRVoting.sol';
import '../OceanMarket.sol';

contract OceanDispute is Ownable {

    using SafeMath for uint256;

    OceanMarket public market;
    OceanRegistry public registry;
    PLCRVoting public voting;

    // complainant is consumer by default
    // voting is needed by default => any dispute needs voting to resolve.
    struct Dispute {
        address complainant;       // complainant address
        bool    resolved;          // Indication of if dispute is resolved
        uint256 pollID;           // identifier for poll
    }
    // mapping from service id or asset id to Dispute struct
    mapping (bytes32 => Dispute) public mDisputes;

    // ------
    // EVENTS
    // ------
    event _DisputeInitiated(address indexed _complainant, bytes32 indexed  _id, uint256 _pollID);
    event _DisputeResolved(address indexed _complainant, bytes32 indexed _id, bool _release, bool _refund);
    // ------------
    // CONSTRUCTOR:
    // ------------

    /**
    @dev Contructor         Sets the addresses
    @param _marketAddr       Address of the marketplace contract
    */
    constructor(address _marketAddr, address _registryAddress, address _plcrAddr) public {
        registry = OceanRegistry(_registryAddress);
        // get instance of OceanMarket
        market = OceanMarket(_marketAddr);
        // add dispute resolution contract address to marketplace contract
        market.addDisputeAddress();
        // add dispute resolution contract address to PLCRVoting contract
        voting = PLCRVoting(_plcrAddr);
        // get instance of dispute inside PLCRVoting contract
        voting.getDisputeInstance(address(this));
    }

    // --------------------
    // Dispute resolution functions
    // --------------------
    /**
    @dev check whether there exists dispute for specific asset or service
    @param id identifier associated with the service（i.e., asset Id or service Id）
    @return valid Boolean indication of if the dispute exists (true: exists, false: none)
    */
    function disputeExist(bytes32 id) public view returns (bool) {
        return (mDisputes[id].complainant != address(0));
    }


    /**
    @dev create dispute and submit proofs for specific service agreement
    @param id identifier associated with the service agreement （i.e., asset Id or service Id）
    @return valid Boolean indication of if the dispute has been initiated
    */
    function initiateDispute(bytes32 id) public returns (uint256) {
        // pause marketplacce to process payment
        market.pausePayment(id);

        // create registry challenge for voting if needed; pollID is used for voting
        uint256 _pollID = registry.challenge(id, '');
        //uint256 _pollID = 0;
        // create Dispute struct
        mDisputes[id] = Dispute({
            complainant: msg.sender,
            resolved: false,
            pollID: _pollID
        });
        emit _DisputeInitiated(msg.sender, id, _pollID);
        return _pollID;
    }

    /**
    @dev add authorized voter into the poll
    @param id identifier associated with the service agreement （i.e., asset Id or service Id）
    @param voter address of voter
    @return valid Boolean indication of if the dispute has been initiated
    */
    function addAuthorizedVoter(bytes32 id, address voter) public onlyOwner() returns (bool) {
        uint pollID = mDisputes[id].pollID;
        require(voting.pollExists(pollID) == true);
        // add authorized voter
        voting.addAuthorizedVoter(pollID, voter);
        return true;
    }

    /**
    @dev check whether voting of poll ends
    @param id identifier associated with the service（i.e., asset Id or service Id）
    @return valid Boolean indication of if the voting ends
    */
    function votingEnded(bytes32 id) public view returns (bool) {
        return registry.challengeCanBeResolved(id);
    }


    /**
    @dev resolve the dispute after the voting ends
    @param id identifier associated with the service
    @return valid Boolean indication of if the dispute has been resolved
    */
    function resolveDispute(bytes32 id) public returns (bool) {
        // voting should be ended at this time
        if(registry.challengeCanBeResolved(id) == false)
            return false;
        // resolve challenge in registry
        registry.updateStatus(id);
        // update status of dispute
        mDisputes[id].resolved = true;

        bool release = false;
        bool refund = false;
        // complainant wins the dispute => refund
        if (!registry.isWhitelisted(id)) {
            refund = true;
        // complainant loses the dispute => release payment
        } else {
            release = true;
        }
        // resolve the dispute and process payments by passing release and refund flags
        market.processPayment(id, release, refund);

        emit _DisputeResolved(msg.sender, id, release, refund);
        return true;
    }

}

pragma solidity 0.4.24;

import '../zeppelin/Ownable.sol';
import '../zeppelin/SafeMath.sol';

/**
@title Ocean Protocol Fishpond Service Contract
@author Team: Bill
*/

contract OceanService is Ownable {

    using SafeMath for uint256;
    using SafeMath for uint;

    // ============
    // DATA STRUCTURES:
    // ============
    struct Service {
        address owner;            // owner of the Service
        string serviceType;       // service type provided
        string endPoint;          // endpoint of the service
    }

    mapping(bytes32 => Service) public mServices;           // mapping serviceId to Service struct


    // ============
    // EVENTS:
    // ============
    event ServiceRegistered(bytes32 indexed _serviceId, address indexed _owner);

    // ============
    // modifier:
    // ============
    modifier validAddress(address sender) {
        require(sender != address(0x0), 'Sender address is 0x0.');
        _;
    }


    /**
    * @dev OceanService Constructor
    * Runs only on initial contract creation.
    */
    constructor() public {
    }

    /**
    * @dev provider register the new service
    * @param serviceId the integer identifier of new service
    * @param serviceType the string representing type of new service
    * @param endPoint the string representing endpoint of new service
    * @return valid Boolean indication of registration of new service
    */
    function register(bytes32 serviceId, string serviceType, string endPoint) public validAddress(msg.sender) returns (bool success) {
        mServices[serviceId] = Service(msg.sender, serviceType, endPoint);
        require(mServices[serviceId].owner == address(0), 'Owner address is not 0x0.');
        emit ServiceRegistered(serviceId, msg.sender);
        return true;
    }




    /**
    * @dev OceanService generates bytes32 identifier for service
    * @param contents the meta data information of service as string
    * @return bytes32 as the identifier of service
    */
    function generateId(string contents) public pure returns (bytes32) {
        // Generate the hash of input string
        return bytes32(keccak256(abi.encodePacked(contents)));
    }

    /**
    * @dev OceanService generates bytes32 identifier for service
    * @param contents the meta data information of service as bytes
    * @return bytes32 as the identifier of service
    */
    function generateId(bytes contents) public pure returns (bytes32) {
        // Generate the hash of input bytes
        return bytes32(keccak256(abi.encodePacked(contents)));
    }



}

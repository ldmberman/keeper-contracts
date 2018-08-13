pragma solidity 0.4.24;

import '../OceanMarket.sol';

contract OceanAuth {

    // marketplace global variables
    OceanMarket private market;

    // Sevice level agreement published on immutable storage
    struct AccessAgreement {
        string accessAgreementRef;  // reference link or i.e IPFS hash
        string accessAgreementType; // type such as PDF/DOC/JSON/XML file.
    }

    // consent (initial agreement) provides details about the service availability given by the provider.
    struct Consent {
        bytes32 resourceId;                   // resource id
        string permissions;                 // comma sparated permissions in one string
        AccessAgreement accessAgreement;
        bool isAvailable;                     // availability of the resource
        uint256 startDate;                  // in seconds
        uint256 expirationDate;                     // in seconds
        string discovery;                   // this is for authorization server configuration in the provider side
        uint256 timeout;                    // if the consumer didn't receive verified claim from the provider within timeout
        // the consumer can cancel the request and refund the payment from market contract
    }

    struct AccessControlRequest {
        address consumer;
        address provider;
        bytes32 resourceId;
        Consent consent;
        string tempPubKey; // temp public key for access token encryption
        bytes encryptedAccessToken;
        AccessStatus status; // Requested, Committed, Delivered, Revoked
    }

    mapping(bytes32 => AccessControlRequest) private accessControlRequests;

    enum AccessStatus {Requested, Committed, Delivered, Revoked}

    // modifiers and access control
    modifier isAccessRequested(bytes32 id) {
        require(accessControlRequests[id].status == AccessStatus.Requested, 'Status not requested.');
        _;
    }

    modifier isAccessCommitted(bytes32 id) {
        require(accessControlRequests[id].status == AccessStatus.Committed, 'Status not Committed.');
        _;
    }

    modifier onlyProvider(bytes32 id) {
        require(accessControlRequests[id].provider == msg.sender, 'Sender is not Provider.');
        _;
    }

    modifier onlyConsumer(bytes32 id) {
        require(accessControlRequests[id].consumer == msg.sender, 'Sender is not consumer.');
        _;
    }

    // events
    event AccessConsentRequested(bytes32 _id, address indexed _consumer, address indexed _provider, bytes32 indexed _resourceId, uint _timeout, string _pubKey);

    event AccessRequestCommitted(bytes32 indexed _id, uint256 _expirationDate, string _discovery, string _permissions, string _accessAgreementRef);

    event AccessRequestRejected(address indexed _consumer, address indexed _provider, bytes32 indexed _id);

    event AccessRequestRevoked(address indexed _consumer, address indexed _provider, bytes32 indexed _id);

    event EncryptedTokenPublished(bytes32 indexed _id, bytes _encryptedAccessToken);

    event AccessRequestDelivered(address indexed _consumer, address indexed _provider, bytes32 indexed _id);

    ///////////////////////////////////////////////////////////////////
    //  Constructor function
    ///////////////////////////////////////////////////////////////////
    // 1. constructor
    constructor(address _marketAddress) public {
        require(_marketAddress != address(0), 'Market address cannot be 0x0');
        // instance of Market
        market = OceanMarket(_marketAddress);
        // add auth contract to access list in market contract - function in market contract
        market.addAuthAddress();
    }

    // 1. Access Request Phase
    function initiateAccessRequest(bytes32 resourceId, address provider, string pubKey, uint256 timeout) public returns (bool) {
        // pasing `id` from outside for debugging purpose; otherwise, generate Id inside automatically
        bytes32 id = keccak256(abi.encodePacked(resourceId, msg.sender, provider, pubKey));
        // initialize AccessAgreement, and claim
        AccessAgreement memory accessAgreement = AccessAgreement(new string(0), new string(0));
        Consent memory consent = Consent(resourceId, new string(0), accessAgreement, false, 0, 0, new string(0), timeout);
        // initialize acl handler
        AccessControlRequest memory accessControlRequest = AccessControlRequest(
            msg.sender,
            provider,
            resourceId,
            consent,
            pubKey, // temp public key
            new bytes(0),
            AccessStatus.Requested // set access status to requested
        );

        accessControlRequests[id] = accessControlRequest;
        emit AccessConsentRequested(id, msg.sender, provider, resourceId, timeout, pubKey);
        return true;
    }

    /* solium-disable-next-line max-len */
    function commitAccessRequest(bytes32 id, bool isAvailable, uint256 expirationDate, string discovery, string permissions, string accessAgreementRef, string accessAgreementType)
    public onlyProvider(id) isAccessRequested(id) returns (bool) {
        /* solium-disable-next-line */
        if (isAvailable && block.timestamp < expirationDate) {
            accessControlRequests[id].consent.isAvailable = isAvailable;
            accessControlRequests[id].consent.expirationDate = expirationDate;
            /* solium-disable-next-line */
            accessControlRequests[id].consent.startDate = block.timestamp;
            accessControlRequests[id].consent.discovery = discovery;
            accessControlRequests[id].consent.permissions = permissions;
            accessControlRequests[id].status = AccessStatus.Committed;
            AccessAgreement memory accessAgreement = AccessAgreement(
                accessAgreementRef,
                accessAgreementType
            );
            accessControlRequests[id].consent.accessAgreement = accessAgreement;
            emit AccessRequestCommitted(id, expirationDate, discovery, permissions, accessAgreementRef);
            return true;
        }

        // otherwise
        accessControlRequests[id].status = AccessStatus.Revoked;
        emit AccessRequestRejected(accessControlRequests[id].consumer, accessControlRequests[id].provider, id);
        return false;
    }

    // you can cancel consent and do refund only after consumer makes the payment and timeout.
    function cancelAccessRequest(bytes32 id) public isAccessCommitted(id) onlyConsumer(id) {
        // timeout
        /* solium-disable-next-line */
        require(block.timestamp > accessControlRequests[id].consent.timeout, 'Timeout not exceeded.');
        accessControlRequests[id].status = AccessStatus.Revoked;
        // refund only if consumer had made payment
        if(market.verifyPaymentReceived(id)){
            require(market.refundPayment(id), 'Refund payment failed.');
        }
        // Always emit this event regardless of payment refund.
        emit AccessRequestRevoked(accessControlRequests[id].consumer, accessControlRequests[id].provider, id);
    }

    //3. Delivery phase
    // provider encypts the JWT using temp public key from cunsumer and publish it to on-chain
    // the encrypted JWT is stored on-chain for alpha version release, which will be moved to off-chain in future versions.
    function deliverAccessToken(bytes32 id, bytes encryptedAccessToken) public onlyProvider(id) isAccessCommitted(id) returns (bool) {
        accessControlRequests[id].encryptedAccessToken = encryptedAccessToken;
        emit EncryptedTokenPublished(id, encryptedAccessToken);
        return true;
    }

    // provider get the temp public key
    function getTempPubKey(bytes32 id) public view onlyProvider(id) isAccessCommitted(id) returns (string) {
        return accessControlRequests[id].tempPubKey;
    }

    // Consumer get the encrypted JWT from on-chain
    function getEncryptedAccessToken(bytes32 id) public view onlyConsumer(id) isAccessCommitted(id) returns (bytes) {
        return accessControlRequests[id].encryptedAccessToken;
    }

    // provider uses this function to verify the signature comes from the consumer
    function isSigned(address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public pure returns (bool) {
        return (ecrecover(msgHash, v, r, s) == _addr);
    }

    // provider verify the access token is delivered to consumer and request for payment
    function verifyAccessTokenDelivery(bytes32 id, address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public
    onlyProvider(id) isAccessCommitted(id) returns (bool) {
        // verify signature from consumer
        if (isSigned(_addr, msgHash, v, r, s)) {
            // send money to provider
            require(market.releasePayment(id), 'Release payment failed.');
            // change status of Request
            accessControlRequests[id].status = AccessStatus.Delivered;
            // emit an event
            emit AccessRequestDelivered(accessControlRequests[id].consumer, accessControlRequests[id].provider, id);
            return true;
        } else {
            accessControlRequests[id].status = AccessStatus.Revoked;
            require(market.refundPayment(id), 'Refund payment failed.');
            emit AccessRequestRevoked(accessControlRequests[id].consumer, accessControlRequests[id].provider, id);
            return false;
        }
    }

    // verify status of access request
    // 0 - Requested; 1 - Committed; 2 - Delivered; 3 - Revoked
    function verifyCommitted(bytes32 id, uint256 status) public view returns (bool) {
        if (status == 0 && accessControlRequests[id].status == AccessStatus.Requested) {
            return true;
        }
        if (status == 1 && accessControlRequests[id].status == AccessStatus.Committed) {
            return true;
        }
        if (status == 2 && accessControlRequests[id].status == AccessStatus.Delivered) {
            return true;
        }
        if (status == 3 && accessControlRequests[id].status == AccessStatus.Revoked) {
            return true;
        }
        return false;
    }

    // Get status of an access request.
    // The status is one of the values of `AccessStatus {Requested, Committed, Delivered, Revoked}`
    function statusOfAccessRequest(bytes32 id) public view returns (uint8) {
        return uint8(accessControlRequests[id].status);
    }

}

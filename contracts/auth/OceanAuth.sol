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
        bytes32 resourceId;                 // resource id
        string permissions;                 // comma sparated permissions in one string
        AccessAgreement accessAgreement;
        bool isAvailable;                   // availability of the resource
        uint256 startDate;                  // in seconds
        uint256 expirationDate;             // in seconds
        string discovery;                   // this is for authorization server configuration in the provider side
        uint256 timeout;                    // if the consumer didn't receive verified claim from the provider within timeout
        // the consumer can cancel the request and refund the payment from market contract
    }

    struct AccessControlRequest {
        address consumer;
        address provider;
        bytes32 resource;
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
    event RequestAccessConsent(bytes32 _id, address _consumer, address _provider, bytes32 _resource, uint _timeout, string _pubKey);

    event CommitConsent(bytes32 _id, uint256 _expirationdate, string _discovery, string _permissions, string _accessAgreementRef);

    event RefundPayment(address _consumer, address _provider, bytes32 _id);

    event PublishEncryptedToken(bytes32 _id, bytes _encryptedAccessToken);

    event ReleasePayment(address _consumer, address _provider, bytes32 _id);

    ///////////////////////////////////////////////////////////////////
    //  Constructor function
    ///////////////////////////////////////////////////////////////////
    // 1. constructor
    constructor(address _marketAddress) public {
        require(_marketAddress != address(0), 'Market address cannot be 0x0');
        // instance of Market
        market = OceanMarket(_marketAddress);
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
        emit RequestAccessConsent(id, msg.sender, provider, resourceId, timeout, pubKey);
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
            emit CommitConsent(id, expirationDate, discovery, permissions, accessAgreementRef);
            return true;
        }

        // otherwise, send refund
        accessControlRequests[id].status = AccessStatus.Revoked;
        require(market.refundPayment(id), 'Refund payment failed.');
        emit RefundPayment(accessControlRequests[id].consumer, accessControlRequests[id].provider, id);
        return false;
    }

    // you can cancel consent and do refund only after timeout.
    function cancelConsent(bytes32 id) public isAccessRequested(id) {
        // timeout
        /* solium-disable-next-line security/no-block-members */
        require(block.timestamp > accessControlRequests[id].consent.timeout, 'Timeout not exceeded.');
        accessControlRequests[id].status = AccessStatus.Revoked;
        require(market.refundPayment(id), 'Refund payment failed.');
        emit RefundPayment(accessControlRequests[id].consumer, accessControlRequests[id].provider, id);
    }

    //3. Delivery phase
    // provider encypts the JWT using temp public key from cunsumer and publish it to on-chain
    // the encrypted JWT is stored on-chain for alpha version release, which will be moved to off-chain in future versions.
    function deliverAccessToken(bytes32 id, bytes encryptedAccessToken) public onlyProvider(id) isAccessCommitted(id) returns (bool) {

        accessControlRequests[id].encryptedAccessToken = encryptedAccessToken;
        emit PublishEncryptedToken(id, encryptedAccessToken);
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
        // expire
        /* solium-disable-next-line */
        if (accessControlRequests[id].consent.expirationDate < block.timestamp) {
            // this means that consumer didn't make the request
            // revoke the access then raise event for refund
            accessControlRequests[id].status = AccessStatus.Revoked;
            require(market.refundPayment(id), 'Refund payment failed.');
            emit RefundPayment(accessControlRequests[id].consumer, accessControlRequests[id].provider, id);
            return false;
        } else {
            // provider confirms that consumer made a request by providing "proof of access"
            if (isSigned(_addr, msgHash, v, r, s)) {
                accessControlRequests[id].status = AccessStatus.Delivered;
                // send money to provider
                require(market.releasePayment(id), 'Release payment failed.');
                // emit an event
                emit ReleasePayment(accessControlRequests[id].consumer, accessControlRequests[id].provider, id);
                return true;
            } else {
                accessControlRequests[id].status = AccessStatus.Revoked;
                require(market.refundPayment(id), 'Refund payment failed.');
                emit RefundPayment(accessControlRequests[id].consumer, accessControlRequests[id].provider, id);
                return false;
            }
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

}

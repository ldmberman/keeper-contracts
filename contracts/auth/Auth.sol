pragma solidity 0.4.24;

import '../Market.sol';

contract Auth {

    // marketplace global variables
    Market  public  market;

    // Sevice level agreement published on immutable storage
    struct SLA {
        string slaRef; // reference link or i.e IPFS hash
        string slaType; // type such as PDF/DOC/JSON/XML file.
    }

    // final agreement
    struct Commitment {
        bytes encJWT;  // encrypted JWT using consumer's temp public key
    }

    // consent (initial agreement) provides details about the service availability given by the provider.
    struct Consent {
        bytes32 resource; // resource id
        string permissions; // comma sparated permissions in one string
        SLA serviceLevelAgreement;
        bool available; // availability of the resource
        uint256 timestamp; // in seconds
        uint256 expire;  // in seconds
        string discovery; // this is for authorization server configuration in the provider side
        uint256 timeout; // if the consumer didn't receive verified claim from the provider within timeout
        // the consumer can cancel the request and refund the payment from market contract
    }

    struct ACL {
        address consumer;
        address provider;
        bytes32 resource;
        Consent consent;
        string pubkey; // temp public key for access token encryption
        Commitment commitment;
        AccessStatus status; // Requested, Committed, Delivered, Revoked
    }

    mapping(bytes32 => ACL) private aclEntries;

    enum AccessStatus {Requested, Committed, Delivered, Revoked}

    // modifiers and access control
    modifier isAccessRequested(bytes32 id) {
        require(aclEntries[id].status == AccessStatus.Requested, 'Status not requested.');
        _;
    }

    modifier isAccessComitted(bytes32 id) {
        require(aclEntries[id].status == AccessStatus.Committed, 'Status not Committed.');
        _;
    }

    modifier onlyProvider(bytes32 id) {
        require(aclEntries[id].provider == msg.sender, 'Sender is not Provider.');
        _;
    }

    modifier onlyConsumer(bytes32 id) {
        require(aclEntries[id].consumer == msg.sender, 'Sender is not consumer.');
        _;
    }

    // events
    event RequestAccessConsent(bytes32 _id, address _consumer, address _provider, bytes32 _resource, uint _timeout, string _pubKey);

    event CommitConsent(bytes32 _id, uint256 _expire, string _discovery, string _permissions, string slaLink);

    event RefundPayment(address _consumer, address _provider, bytes32 _id);

    event PublishEncryptedToken(bytes32 _id, bytes encJWT);

    event ReleasePayment(address _consumer, address _provider, bytes32 _id);

    ///////////////////////////////////////////////////////////////////
    //  Constructor function
    ///////////////////////////////////////////////////////////////////
    // 1. constructor
    function Auth(address _marketAddress) public {
        require(_marketAddress != address(0), 'Market address cannot be 0x0');
        // instance of Market
        market = Market(_marketAddress);
    }

    //1. Access Request Phase
    function initiateAccessRequest(bytes32 resourceId, address provider, string pubKey, uint256 timeout)
    public returns (bool) {
        // pasing `id` from outside for debugging purpose; otherwise, generate Id inside automatically
        bytes32 id = keccak256(resourceId, msg.sender, provider, pubKey);
        // initialize SLA, Commitment, and claim
        SLA memory sla = SLA(new string(0), new string(0));
        Commitment memory commitment = Commitment(new bytes(0));
        Consent memory consent = Consent(resourceId, new string(0), sla, false, 0, 0, new string(0), timeout);
        // initialize acl handler
        ACL memory acl = ACL(
            msg.sender,
            provider,
            resourceId,
            consent,
            pubKey, // temp public key
            commitment,
            AccessStatus.Requested // set access status to requested
        );

        aclEntries[id] = acl;
        emit RequestAccessConsent(id, msg.sender, provider, resourceId, timeout, pubKey);
        return true;
    }

    /* solium-disable-next-line */
    function commitAccessRequest(bytes32 id, bool available, uint256 expire, string discovery, string permissions, string slaLink, string slaType)
    public onlyProvider(id) isAccessRequested(id) returns (bool) {
        /* solium-disable-next-line */
        if (available && block.timestamp < expire) {
            aclEntries[id].consent.available = available;
            aclEntries[id].consent.expire = expire;
            /* solium-disable-next-line */
            aclEntries[id].consent.timestamp = block.timestamp;
            aclEntries[id].consent.discovery = discovery;
            aclEntries[id].consent.permissions = permissions;
            aclEntries[id].status = AccessStatus.Committed;
            SLA memory sla = SLA(
                slaLink,
                slaType
            );
            aclEntries[id].consent.serviceLevelAgreement = sla;
            emit CommitConsent(id, expire, discovery, permissions, slaLink);
            return true;
        }

        // otherwise, send refund
        aclEntries[id].status = AccessStatus.Revoked;
        require(market.refundPayment(id), 'Refund payment failed.');
        emit RefundPayment(aclEntries[id].consumer, aclEntries[id].provider, id);
        return false;
    }

    // you can cancel consent and do refund only after timeout.
    function cancelConsent(bytes32 id)
    public
    isAccessRequested(id) {
        // timeout
        /* solium-disable-next-line */
        require(block.timestamp > aclEntries[id].consent.timeout, 'Timeout not exceeded.');
        aclEntries[id].status = AccessStatus.Revoked;
        require(market.refundPayment(id), 'Refund payment failed.');
        emit RefundPayment(aclEntries[id].consumer, aclEntries[id].provider, id);
    }

    //3. Delivery phase
    // provider encypts the JWT using temp public key from cunsumer and publish it to on-chain
    // the encrypted JWT is stored on-chain for alpha version release, which will be moved to off-chain in future versions.
    function deliverAccessToken(bytes32 id, bytes encryptedJWT) public onlyProvider(id) isAccessComitted(id) returns (bool) {

        aclEntries[id].commitment.encJWT = encryptedJWT;
        emit PublishEncryptedToken(id, encryptedJWT);
        return true;
    }

    // provider get the temp public key
    function getTempPubKey(bytes32 id) public view onlyProvider(id) isAccessComitted(id) returns (string) {
        return aclEntries[id].pubkey;
    }

    // Consumer get the encrypted JWT from on-chain
    function getEncJWT(bytes32 id) public view onlyConsumer(id) isAccessComitted(id) returns (bytes) {
        return aclEntries[id].commitment.encJWT;
    }


    // provider uses this function to verify the signature comes from the consumer
    function isSigned(address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public view returns (bool){
        return (ecrecover(msgHash, v, r, s) == _addr);
    }

    // provider verify the access token is delivered to consumer and request for payment
    function verifyAccessTokenDelivery(bytes32 id, address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public
    onlyProvider(id) isAccessComitted(id) returns (bool){
        // expire
        /* solium-disable-next-line */
        if (aclEntries[id].consent.expire < block.timestamp) {
            // this means that consumer didn't make the request
            // revoke the access then raise event for refund
            aclEntries[id].status = AccessStatus.Revoked;
            require(market.refundPayment(id), 'Refund payment failed.');
            emit RefundPayment(aclEntries[id].consumer, aclEntries[id].provider, id);
            return false;
        } else {
            // provider confirms that consumer made a request by providing "proof of access"
            if (isSigned(_addr, msgHash, v, r, s)) {
                aclEntries[id].status = AccessStatus.Delivered;
                // send money to provider
                require(market.releasePayment(id), 'Release payment failed.');
                // emit an event
                emit ReleasePayment(aclEntries[id].consumer, aclEntries[id].provider, id);
                return true;
            } else {
                aclEntries[id].status = AccessStatus.Revoked;
                require(market.refundPayment(id), 'Refund payment failed.');
                emit RefundPayment(aclEntries[id].consumer, aclEntries[id].provider, id);
                return false;
            }
        }
    }

    // verify status of access request
    // 0 - Requested; 1 - Committed; 2 - Delivered; 3 - Revoked
    function verifyCommitted(bytes32 id, uint256 status) public view returns (bool) {
        if (status == 0 && aclEntries[id].status == AccessStatus.Requested) {
            return true;
        }
        if (status == 1 && aclEntries[id].status == AccessStatus.Committed) {
            return true;
        }
        if (status == 2 && aclEntries[id].status == AccessStatus.Delivered) {
            return true;
        }
        if (status == 3 && aclEntries[id].status == AccessStatus.Revoked) {
            return true;
        }
        return false;
    }

}

pragma solidity 0.4.21;


contract Auth {

    // Sevice level agreement published on immutable storage
    struct SLA {
        string slaRef; // reference link or i.e IPFS hash
        string slaType; // type such as PDF/DOC/JSON/XML file.
    }

    // final agreement
    struct Commitment {
        bytes32 jwtHash; // committed by the provider (it could be ssh keys/ jwt token/ OTP)
        string encJWT;  // encrypted JWT using consumer's temp public key
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
        bytes pubkey; // temp public key for access token encryption
        Commitment commitment;
        string status; // Requested, Committed, Delivered, Revoked
    }

    mapping(bytes32 => ACL) private aclEntries;

    enum AccessStatus {Requested, Committed, Delivered, Revoked}

    // modifiers and access control
    modifier isAccessRequested(bytes32 challenge) {
        require(aclEntries[challenge].status == string(AccessStatus.Requested));
        _;
    }

    modifier isAccessComitted(bytes32 challenge) {
        require(aclEntries[challenge].status == string(AccessStatus.Comitted));
        _;
    }
    modifier onlyProvider(bytes32 challenge) {
        require(aclEntries[challenge].provider == msg.sender);
        _;
    }

    modifier onlyConsumer(bytes32 challenge) {
        require(aclEntries[challenge].consumer == msg.sender);
        _;
    }

    // events
    event RequestAccessConsent(bytes32 _challenge, address _consumer, address _provider, byte32 _paymentReceipt, bytes32 _resource, uint _timeout);
    event IssueConsent(bytes32 _challenge, address _consumer, address _provider, uint256 _expire, string _discovery, bytes32 _resource, string _permissions, string slaLink);
    event RefundPayment(address _consumer, address _provider, bytes32 _challenge, bytes32 _receipt, string _status);
    event PublishEncryptedToken(bytes32 _challenge, string encJWT);
    event ReleasePayment(address _consumer, address _provider, bytes32 _challenge, bytes32 _receipt, string _status);

    //1. Access Request Phase
    function initiateAccessRequest(bytes32 resourceId, address provider, bytes pubKey, uint256 timeout)
    public returns (bool) {
        require(msg.sender != provider);
        // generate challege id
        bytes32 challengeId = keccak256(abi.encodePacked(resourceId, msg.sender, provider, pubKey, timeout));
        // initialize SLA, Commitment, and claim
        SLA memory sla = SLA(new string(0), new string(0));
        Commitment memory commitment = Commitment(bytes32(0), bytes32(0), false);
        Consent memory consent = Consent(resourceId, new string(0), sla, false, 0, 0, new string(0), timeout);
        // initialize acl handler
        ACL memory acl = ACL(
            msg.sender,
            provider,
            resourceId,
            consent,
            pubKey, // temp public key
            commitment,
            string(AccessStatus.Requested) // set access status to requested
        );
        aclEntries[challengeId] = acl;
        emit RequestAccessConsent(challengeId, msg.sender, provider, paymentReceipt, resourceId, timeout);

        return true;
    }

    // provider commit the Access Request
    function commitAccessRequest(bytes32 challenge, bool available, uint256 expire, string discovery,
        string permissions, string slaLink, string slaType, bytes32 jwtHash)
    public
    onlyProvider
    isAccessRequested(challenge) returns (bool) {
        if (available && now < expire) {
            aclEntries[challenge].consent.available = available;
            aclEntries[challenge].consent.expire = expire;
            aclEntries[challenge].consent.timestamp = now;
            aclEntries[challenge].consent.discovery = discovery;
            aclEntries[challenge].consent.permissions = permissions;
            accessHandlers[challenge].commitment.jwtHash = jwtHash;
            aclEntries[challenge].status = string(AccessStatus.Committed);
            SLA memory sla = SLA(
                slaLink,
                slaType
            );
            aclEntries[challenge].consent.serviceLevelAgreement = sla;
            emit IssueConsent(challenge, consumer, provider, expire, discovery, aclEntries[challenge].consent.resource,
                permissions, slaLink);
            return true;
        }

        // otherwise, send refund
        aclEntries[challenge].status = string(AccessStatus.Revoked);
        emit RefundPayment(aclEntries[challenge].consumer, aclEntries[challenge].provider, challenge,
            acccessHandlers[challenge].receipt, aclEntries[challenge].status);
        return false;
    }

    // you can cancel consent and do refund only after timeout.
    function cancelConsent(bytes32 challenge)
    public
    isAccessRequested(challenge) {
        // timeout
        if (now > aclEntries[challenge].consent.timeout) {
            aclEntries[challenge].status = string(AccessStatus.Revoked);
            emit RefundPayment(aclEntries[challenge].consumer, aclEntries[challenge].provider, challenge,
                acccessHandlers[challenge].receipt, aclEntries[challenge].status);
        }
    }

    // 2. consumer make payments via Market contract
    //    consumer does not need to commit again; once consumer makes payment, he commits at the same time.
    //3. Delivery phase
    // provider encypts the JWT using temp public key from cunsumer and publish it to on-chain
    function deliverAccessToken(bytes32 challenge, string encryptedJWT)
    public onlyProvider isAccessCommitted(challenge) returns (bool) {

        accessHandlers[challenge].commitment.encJWT = encryptedJWT;
        emit PublishEncryptedToken(challenge, encJWT);
        return true;
    }

    // Consumer get the encrypted JWT from on-chain
    function getEncJWT(bytes32 challenge)
    public view
    onlyConsumer
    isAccessCommitted(challenge) returns (string) {
        return accessHandlers[challenge].commitment.encJWT;
    }

    /*
    Off-chain activities:
    1. consumer decrypt the encJWT using temp private key;
    2. consumer encrypt JWT using wallet private key and send signedJWT to provider with off-chain communication
    3. provide decrypt signedJWT with consumer wallet public key
    4. In order to release the payment the provider should provide a proof of access
    by calling verifyAccessTokenDelivery comparing (encJWT, signedEncJWT, consumer pubkey)

    On-chain activity:
    1. provider verify the challege is not expired
    2. provider verify `bytes32 signedJWTHash` matches the original JWT hash generated by himself
    */
    function verifyJWT(bytes32 challenge, bytes signedEncJWT) private {
        //TODO: proof of access
        // verify the consumer's signature (aclEntries[challenge].commetment.encJWT, signedEncJWT, aclEntries[challenge].consumer)
        return true;
    }

    function verifyAccessTokenDelivery(bytes challenge, string signedEncJWT) public onlyProvider
    isAccessCommitted(challenge) {

        // expire
        if (accessHandler[challenge].consent.expire < now) {
            // this means that consumer didn't make the request
            // revoke the access then raise event for refund
            aclEntries[challenge].status = string(AccessStatus.Revoked);
            emit RefundPayment(aclEntries[challenge].consumer, aclEntries[challenge].provider, challenge,
                acccessHandlers[challenge].receipt, aclEntries[challenge].status);
        } else {
            // provider confirms that consumer made a request by providing "proof of access"
            // This means that provider should get a signed jwt hash from the consumer and compares what was
            // committed by the provider with the signed one.
            if (verifyJWT(challenge, signedEncJWT)) {
                aclEntries[challenge].status = string(AccessStatus.Delivered);
                // send money to provider
                emit ReleasePayment(aclEntries[challenge].consumer, aclEntries[challenge].provider, challenge,
                    acccessHandlers[challenge].receipt, aclEntries[challenge].status);
            } else {
                aclEntries[challenge].status = string(AccessStatus.Revoked);
                emit RefundPayment(aclEntries[challenge].consumer, aclEntries[challenge].provider, challenge,
                    acccessHandlers[challenge].receipt, aclEntries[challenge].status);
            }
        }
    }

    // Utility function: provider/consumer use this function to check access request status
    function verifyAccessStatus(bytes32 challenge, string status) public returns (bool) {
        if (aclEntries[challenge].status == status) {
            return true;
        }
        return false;
    }

}

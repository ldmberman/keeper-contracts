# Analysis result for DLL

No issues found.
# Analysis results for AttributeStore.sol

## Integer Overflow

- Type: Warning
- Contract: AttributeStore
- Function name: `fallback`
- PC address: 117

### Description

A possible integer overflow exists in the function `fallback`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: AttributeStore.sol:8

### Code

```
function getAttribute(Data storage self, bytes32 _UUID, string _attrName)
    public view returns (uint) {
        bytes32 key = keccak256(abi.encodePacked(_UUID, _attrName));
        return self.store[key];
    }
```

# Analysis result for PLCRVoting

No issues found.
# Analysis results for OceanRegistry.sol

## Message call to external contract

- Type: Informational
- Contract: OceanRegistry
- Function name: `withdraw(bytes32,uint256)`
- PC address: 1427

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanRegistry.sol:139

### Code

```
token.transfer(msg.sender, _amount)
```

## Integer Overflow

- Type: Warning
- Contract: OceanRegistry
- Function name: `deposit(bytes32,uint256)`
- PC address: 2209

### Description

A possible integer overflow exists in the function `deposit(bytes32,uint256)`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: OceanRegistry.sol:119

### Code

```
listing.unstakedDeposit += _amount
```

## Message call to external contract

- Type: Informational
- Contract: OceanRegistry
- Function name: `deposit(bytes32,uint256)`
- PC address: 2327

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanRegistry.sol:120

### Code

```
token.transferFrom(msg.sender, this, _amount)
```

## Message call to external contract

- Type: Informational
- Contract: OceanRegistry
- Function name: `challenge(bytes32,string)`
- PC address: 2966

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanRegistry.sol:192

### Code

```
voting.startPoll(
            50, //parameterizer.get('voteQuorum'),
            1 hours, //parameterizer.get('commitStageLen'),
            1 hours  //parameterizer.get('revealStageLen')
        )
```

## Multiple Calls

- Type: Information
- Contract: OceanRegistry
- Function name: `challenge(bytes32,string)`
- PC address: 2966

### Description

Multiple sends exist in one transaction, try to isolate each external call into its own transaction. As external calls can fail accidentally or deliberately.
Consecutive calls: 
Call at address: 3313
In file: OceanRegistry.sol:192

### Code

```
voting.startPoll(
            50, //parameterizer.get('voteQuorum'),
            1 hours, //parameterizer.get('commitStageLen'),
            1 hours  //parameterizer.get('revealStageLen')
        )
```

## State change after external call

- Type: Warning
- Contract: OceanRegistry
- Function name: `challenge(bytes32,string)`
- PC address: 3079

### Description

The contract account state is changed after an external call. Consider that the called contract could re-enter the function before this state change takes place. This can lead to business logic vulnerabilities.
In file: OceanRegistry.sol:198

### Code

```
challenges[pollID] = Challenge({
            challenger : msg.sender,
            //parameterizer.get('dispensationPct') = 50
            rewardPool : ((100 - 50) * minDeposit) / 100,
            stake : minDeposit,
            resolved : false,
            totalTokens : 0
            })
```

## State change after external call

- Type: Warning
- Contract: OceanRegistry
- Function name: `challenge(bytes32,string)`
- PC address: 3169

### Description

The contract account state is changed after an external call. Consider that the called contract could re-enter the function before this state change takes place. This can lead to business logic vulnerabilities.
In file: OceanRegistry.sol:198

### Code

```
challenges[pollID] = Challenge({
            challenger : msg.sender,
            //parameterizer.get('dispensationPct') = 50
            rewardPool : ((100 - 50) * minDeposit) / 100,
            stake : minDeposit,
            resolved : false,
            totalTokens : 0
            })
```

## State change after external call

- Type: Warning
- Contract: OceanRegistry
- Function name: `challenge(bytes32,string)`
- PC address: 3182

### Description

The contract account state is changed after an external call. Consider that the called contract could re-enter the function before this state change takes place. This can lead to business logic vulnerabilities.
In file: OceanRegistry.sol:198

### Code

```
challenges[pollID] = Challenge({
            challenger : msg.sender,
            //parameterizer.get('dispensationPct') = 50
            rewardPool : ((100 - 50) * minDeposit) / 100,
            stake : minDeposit,
            resolved : false,
            totalTokens : 0
            })
```

## State change after external call

- Type: Warning
- Contract: OceanRegistry
- Function name: `challenge(bytes32,string)`
- PC address: 3193

### Description

The contract account state is changed after an external call. Consider that the called contract could re-enter the function before this state change takes place. This can lead to business logic vulnerabilities.
In file: OceanRegistry.sol:198

### Code

```
challenges[pollID] = Challenge({
            challenger : msg.sender,
            //parameterizer.get('dispensationPct') = 50
            rewardPool : ((100 - 50) * minDeposit) / 100,
            stake : minDeposit,
            resolved : false,
            totalTokens : 0
            })
```

## State change after external call

- Type: Warning
- Contract: OceanRegistry
- Function name: `challenge(bytes32,string)`
- PC address: 3199

### Description

The contract account state is changed after an external call. Consider that the called contract could re-enter the function before this state change takes place. This can lead to business logic vulnerabilities.
In file: OceanRegistry.sol:208

### Code

```
listing.challengeID = pollID
```

## State change after external call

- Type: Warning
- Contract: OceanRegistry
- Function name: `challenge(bytes32,string)`
- PC address: 3209

### Description

The contract account state is changed after an external call. Consider that the called contract could re-enter the function before this state change takes place. This can lead to business logic vulnerabilities.
In file: OceanRegistry.sol:211

### Code

```
listing.unstakedDeposit -= minDeposit
```

## Message call to external contract

- Type: Informational
- Contract: OceanRegistry
- Function name: `challenge(bytes32,string)`
- PC address: 3313

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanRegistry.sol:214

### Code

```
token.transferFrom(msg.sender, this, minDeposit)
```

## Message call to external contract

- Type: Informational
- Contract: OceanRegistry
- Function name: `challengeCanBeResolved(bytes32)`
- PC address: 4143

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanRegistry.sol:352

### Code

```
voting.pollEnded(challengeID)
```

## Message call to external contract

- Type: Informational
- Contract: OceanRegistry
- Function name: `claimReward(uint256,uint256)`
- PC address: 4544

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanRegistry.sol:260

### Code

```
voting.getNumPassingTokens(msg.sender, _challengeID, _salt)
```

## Multiple Calls

- Type: Information
- Contract: OceanRegistry
- Function name: `claimReward(uint256,uint256)`
- PC address: 4544

### Description

Multiple sends exist in one transaction, try to isolate each external call into its own transaction. As external calls can fail accidentally or deliberately.
Consecutive calls: 
Call at address: 6014
In file: OceanRegistry.sol:260

### Code

```
voting.getNumPassingTokens(msg.sender, _challengeID, _salt)
```

## Integer Overflow

- Type: Warning
- Contract: OceanRegistry
- Function name: `apply(bytes32,uint256,string)`
- PC address: 5244

### Description

A possible integer overflow exists in the function `apply(bytes32,uint256,string)`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: OceanRegistry.sol:95

### Code

```
listing.owner = msg.sender
```

## Message call to external contract

- Type: Informational
- Contract: OceanRegistry
- Function name: `claimReward(uint256,uint256)`
- PC address: 6014

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanRegistry.sol:291

### Code

```
voting.getNumPassingTokens(_voter, _challengeID, _salt)
```

## Exception state

- Type: Informational
- Contract: OceanRegistry
- Function name: `claimReward(uint256,uint256)`
- PC address: 6069

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: OceanRegistry.sol:292

### Code

```
(voterTokens * rewardPool) / totalTokens
```

## Message call to external contract

- Type: Informational
- Contract: OceanRegistry
- Function name: `exit(bytes32)`
- PC address: 7006

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanRegistry.sol:453

### Code

```
token.transfer(owner, unstakedDeposit)
```

## Exception state

- Type: Informational
- Contract: OceanRegistry
- Function name: `apply(bytes32,uint256,string)`
- PC address: 7135

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: OceanRegistry.sol:24

### Code

```
tingWithdrawn(
```

# Analysis results for OceanAuth.sol

## Integer Overflow

- Type: Warning
- Contract: OceanAuth
- Function name: `initiateAccessRequest(bytes32,address,string,uint256)`
- PC address: 303

### Description

A possible integer overflow exists in the function `initiateAccessRequest(bytes32,address,string,uint256)`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: OceanAuth.sol:109

### Code

```
function initiateAccessRequest(bytes32 resourceId, address provider, string pubKey, uint256 timeout) public returns (bool) {
        bytes32 id = keccak256(abi.encodePacked(resourceId, msg.sender, provider, pubKey));
        AccessAgreement memory accessAgreement = AccessAgreement(new string(0), new string(0));
        Consent memory consent = Consent(resourceId, new string(0), accessAgreement, false, 0, 0, new string(0), timeout);
        AccessControlRequest memory accessControlRequest = AccessControlRequest(
            msg.sender,
            provider,
            resourceId,
            consent,
            pubKey,
            new bytes(0),
            AccessStatus.Requested
        );

        accessControlRequests[id] = accessControlRequest;
        emit AccessConsentRequested(id, msg.sender, provider, resourceId, timeout, pubKey);
        return true;
    }
```

## Integer Overflow

- Type: Warning
- Contract: OceanAuth
- Function name: `deliverAccessToken(bytes32,bytes)`
- PC address: 411

### Description

A possible integer overflow exists in the function `deliverAccessToken(bytes32,bytes)`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: OceanAuth.sol:193

### Code

```
function deliverAccessToken(bytes32 id, bytes encryptedAccessToken) public onlyProvider(id) isAccessCommitted(id) returns (bool) {
        accessControlRequests[id].encryptedAccessToken = encryptedAccessToken;
        accessControlRequests[id].status = AccessStatus.Delivered;
        emit EncryptedTokenPublished(id, encryptedAccessToken);
        return true;
    }
```

## Integer Overflow

- Type: Warning
- Contract: OceanAuth
- Function name: `commitAccessRequest(bytes32,bool,uint256,string,string,string,string)`
- PC address: 506

### Description

A possible integer overflow exists in the function `commitAccessRequest(bytes32,bool,uint256,string,string,string,string)`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: OceanAuth.sol:139

### Code

```
function commitAccessRequest(
        bytes32 id,
        bool isAvailable,
        uint256 expirationDate,
        string discovery,
        string permissions,
        string accessAgreementRef,
        string accessAgreementType)
    public onlyProvider(id) isAccessRequested(id) returns (bool) {
        /* solium-disable-next-line security/no-block-members */
        if (isAvailable && block.timestamp < expirationDate) {
            accessControlRequests[id].consent.isAvailable = isAvailable;
            accessControlRequests[id].consent.expirationDate = expirationDate;
            /* solium-disable-next-line security/no-block-members */
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
```

## Message call to external contract

- Type: Informational
- Contract: OceanAuth
- Function name: `verifyAccessTokenDelivery(bytes32,address,bytes32,uint8,bytes32,bytes32)`
- PC address: 1341

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanAuth.sol:61

### Code

```
market.verifyPaymentReceived(id)
```

## Multiple Calls

- Type: Information
- Contract: OceanAuth
- Function name: `verifyAccessTokenDelivery(bytes32,address,bytes32,uint8,bytes32,bytes32)`
- PC address: 1341

### Description

Multiple sends exist in one transaction, try to isolate each external call into its own transaction. As external calls can fail accidentally or deliberately.
Consecutive calls: 
Call at address: 1712
Call at address: 2076
In file: OceanAuth.sol:61

### Code

```
market.verifyPaymentReceived(id)
```

## Exception state

- Type: Informational
- Contract: OceanAuth
- Function name: `verifyAccessTokenDelivery(bytes32,address,bytes32,uint8,bytes32,bytes32)`
- PC address: 1501

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: OceanAuth.sol:62

### Code

```
accessControlRequests[id].status == AccessStatus.Delivered
```

## Message call to external contract

- Type: Informational
- Contract: OceanAuth
- Function name: `verifyAccessTokenDelivery(bytes32,address,bytes32,uint8,bytes32,bytes32)`
- PC address: 1712

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanAuth.sol:246

### Code

```
market.releasePayment(id)
```

## State change after external call

- Type: Warning
- Contract: OceanAuth
- Function name: `verifyAccessTokenDelivery(bytes32,address,bytes32,uint8,bytes32,bytes32)`
- PC address: 1871

### Description

The contract account state is changed after an external call. Consider that the called contract could re-enter the function before this state change takes place. This can lead to business logic vulnerabilities.
In file: OceanAuth.sol:248

### Code

```
accessControlRequests[id].status = AccessStatus.Verified
```

## State change after external call

- Type: Warning
- Contract: OceanAuth
- Function name: `verifyAccessTokenDelivery(bytes32,address,bytes32,uint8,bytes32,bytes32)`
- PC address: 1975

### Description

The contract account state is changed after an external call. Consider that the called contract could re-enter the function before this state change takes place. This can lead to business logic vulnerabilities.
In file: OceanAuth.sol:253

### Code

```
accessControlRequests[id].status = AccessStatus.Revoked
```

## Message call to external contract

- Type: Informational
- Contract: OceanAuth
- Function name: `verifyAccessTokenDelivery(bytes32,address,bytes32,uint8,bytes32,bytes32)`
- PC address: 2076

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanAuth.sol:254

### Code

```
market.refundPayment(id)
```

## Exception state

- Type: Informational
- Contract: OceanAuth
- Function name: `deliverAccessToken(bytes32,bytes)`
- PC address: 3574

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: OceanAuth.sol:57

### Code

```
accessControlRequests[id].status == AccessStatus.Committed
```

## Exception state

- Type: Informational
- Contract: OceanAuth
- Function name: `commitAccessRequest(bytes32,bool,uint256,string,string,string,string)`
- PC address: 4031

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: OceanAuth.sol:52

### Code

```
accessControlRequests[id].status == AccessStatus.Requested
```

## Message call to external contract

- Type: Informational
- Contract: OceanAuth
- Function name: `getEncryptedAccessToken(bytes32)`
- PC address: 5067

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanAuth.sol:61

### Code

```
market.verifyPaymentReceived(id)
```

## Exception state

- Type: Informational
- Contract: OceanAuth
- Function name: `getEncryptedAccessToken(bytes32)`
- PC address: 5227

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: OceanAuth.sol:62

### Code

```
accessControlRequests[id].status == AccessStatus.Delivered
```

## Integer Overflow

- Type: Warning
- Contract: OceanAuth
- Function name: `getEncryptedAccessToken(bytes32)`
- PC address: 5355

### Description

A possible integer overflow exists in the function `getEncryptedAccessToken(bytes32)`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: OceanAuth.sol:215

### Code

```
return accessControlRequests[id].encryptedAccessToken
```

## Exception state

- Type: Informational
- Contract: OceanAuth
- Function name: `cancelAccessRequest(bytes32)`
- PC address: 5513

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: OceanAuth.sol:57

### Code

```
accessControlRequests[id].status == AccessStatus.Committed
```

## Message call to external contract

- Type: Informational
- Contract: OceanAuth
- Function name: `cancelAccessRequest(bytes32)`
- PC address: 5922

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanAuth.sol:179

### Code

```
market.verifyPaymentReceived(id)
```

## Multiple Calls

- Type: Information
- Contract: OceanAuth
- Function name: `cancelAccessRequest(bytes32)`
- PC address: 5922

### Description

Multiple sends exist in one transaction, try to isolate each external call into its own transaction. As external calls can fail accidentally or deliberately.
Consecutive calls: 
Call at address: 6075
In file: OceanAuth.sol:179

### Code

```
market.verifyPaymentReceived(id)
```

## Message call to external contract

- Type: Informational
- Contract: OceanAuth
- Function name: `cancelAccessRequest(bytes32)`
- PC address: 6075

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanAuth.sol:180

### Code

```
market.refundPayment(id)
```

## Exception state

- Type: Informational
- Contract: OceanAuth
- Function name: `statusOfAccessRequest(bytes32)`
- PC address: 6331

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: OceanAuth.sol:266

### Code

```
uint8(accessControlRequests[id].status)
```

## Exception state

- Type: Informational
- Contract: OceanAuth
- Function name: `getTempPubKey(bytes32)`
- PC address: 6473

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: OceanAuth.sol:57

### Code

```
accessControlRequests[id].status == AccessStatus.Committed
```

## Integer Overflow

- Type: Warning
- Contract: OceanAuth
- Function name: `getTempPubKey(bytes32)`
- PC address: 6601

### Description

A possible integer overflow exists in the function `getTempPubKey(bytes32)`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: OceanAuth.sol:206

### Code

```
return accessControlRequests[id].tempPubKey
```

## Integer Overflow

- Type: Warning
- Contract: OceanAuth
- Function name: `deliverAccessToken(bytes32,bytes)`
- PC address: 6874

### Description

A possible integer overflow exists in the function `deliverAccessToken(bytes32,bytes)`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: OceanAuth.sol:9

### Code

```
contract OceanAuth {

    // ============
    // DATA STRUCTURES:
    // ============
    OceanMarket private market;

    // Sevice level agreement published on immutable storage
    struct AccessAgreement {
        string accessAgreementRef;  // reference link or i.e IPFS hash
        string accessAgreementType; // type such as PDF/DOC/JSON/XML file.
    }

    // consent (initial agreement) provides details about the service
    struct Consent {
        bytes32 resourceId;
        string permissions;
        AccessAgreement accessAgreement;
        bool isAvailable;
        uint256 startDate;
        uint256 expirationDate;
        string discovery;
        uint256 timeout;
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

    enum AccessStatus {Requested, Committed, Delivered, Verified, Revoked}

    // ============
    // modifier:
    // ============
    modifier isAccessRequested(bytes32 id) {
        require(accessControlRequests[id].status == AccessStatus.Requested, 'Status not requested.');
        _;
    }

    modifier isAccessCommitted(bytes32 id) {
        require(accessControlRequests[id].status == AccessStatus.Committed, 'Status not Committed.');
        _;
    }
    modifier isAccessDelivered(bytes32 id) {
        require(market.verifyPaymentReceived(id), 'payment not received');
        require(accessControlRequests[id].status == AccessStatus.Delivered, 'Status not Delivered.');
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

    // ============
    // EVENTS:
    // ============
    /* solium-disable-next-line max-len */
    event AccessConsentRequested(bytes32 _id, address indexed _consumer, address indexed _provider, bytes32 indexed _resourceId, uint _timeout, string _pubKey);
    /* solium-disable-next-line max-len */
    event AccessRequestCommitted(bytes32 indexed _id, uint256 _expirationDate, string _discovery, string _permissions, string _accessAgreementRef);
    event AccessRequestRejected(address indexed _consumer, address indexed _provider, bytes32 indexed _id);
    event AccessRequestRevoked(address indexed _consumer, address indexed _provider, bytes32 indexed _id);
    event EncryptedTokenPublished(bytes32 indexed _id, bytes _encryptedAccessToken);
    event AccessRequestDelivered(address indexed _consumer, address indexed _provider, bytes32 indexed _id);

    /**
    * @dev OceanAuth Constructor
    * @param _marketAddress The deployed contract address of Ocean marketplace
    * Runs only on initial contract creation.
    */
    constructor(address _marketAddress) public {
        require(_marketAddress != address(0), 'Market address cannot be 0x0');
        // instance of Market
        market = OceanMarket(_marketAddress);
        // add auth contract to access list in market contract - function in market contract
        market.addAuthAddress();
    }

    /**
    @dev consumer initiates access request of service
    @param resourceId identifier associated with resource
    @param provider provider address of the requested resource
    @param pubKey the temporary public key generated by consumer in local
    @param timeout the expiration time of access request in seconds
    @return valid Boolean indication of if the access request has been submitted successfully
    */
    function initiateAccessRequest(bytes32 resourceId, address provider, string pubKey, uint256 timeout) public returns (bool) {
        bytes32 id = keccak256(abi.encodePacked(resourceId, msg.sender, provider, pubKey));
        AccessAgreement memory accessAgreement = AccessAgreement(new string(0), new string(0));
        Consent memory consent = Consent(resourceId, new string(0), accessAgreement, false, 0, 0, new string(0), timeout);
        AccessControlRequest memory accessControlRequest = AccessControlRequest(
            msg.sender,
            provider,
            resourceId,
            consent,
            pubKey,
            new bytes(0),
            AccessStatus.Requested
        );

        accessControlRequests[id] = accessControlRequest;
        emit AccessConsentRequested(id, msg.sender, provider, resourceId, timeout, pubKey);
        return true;
    }

    /**
    @dev provider commits the access request of service
    @param id identifier associated with the access request
    @param isAvailable boolean indication of the avaiability of resource
    @param expirationDate the expiration time of access request in seconds
    @param discovery  authorization server configuration in the provider side
    @param permissions comma sparated permissions in one string
    @param accessAgreementRef reference link or i.e IPFS hash
    @param accessAgreementType type such as PDF/DOC/JSON/XML file.
    @return valid Boolean indication of if the access request has been committed successfully
    */
    function commitAccessRequest(
        bytes32 id,
        bool isAvailable,
        uint256 expirationDate,
        string discovery,
        string permissions,
        string accessAgreementRef,
        string accessAgreementType)
    public onlyProvider(id) isAccessRequested(id) returns (bool) {
        /* solium-disable-next-line security/no-block-members */
        if (isAvailable && block.timestamp < expirationDate) {
            accessControlRequests[id].consent.isAvailable = isAvailable;
            accessControlRequests[id].consent.expirationDate = expirationDate;
            /* solium-disable-next-line security/no-block-members */
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
        /* solium-disable-next-line security/no-block-members */
        require(block.timestamp > accessControlRequests[id].consent.timeout, 'Timeout not exceeded.');

        // refund only if consumer had made payment
        if (market.verifyPaymentReceived(id)) {
            require(market.refundPayment(id), 'Refund payment failed.');
        }
        // Always emit this event regardless of payment refund.
        accessControlRequests[id].status = AccessStatus.Revoked;
        emit AccessRequestRevoked(accessControlRequests[id].consumer, accessControlRequests[id].provider, id);
    }

    /**
    @dev provider delivers the access token of service to on-chain
    @param id identifier associated with the access request
    @param encryptedAccessToken the encrypted access token of resource
    @return valid Boolean indication of if the access token has been delivered
    */
    function deliverAccessToken(bytes32 id, bytes encryptedAccessToken) public onlyProvider(id) isAccessCommitted(id) returns (bool) {
        accessControlRequests[id].encryptedAccessToken = encryptedAccessToken;
        accessControlRequests[id].status = AccessStatus.Delivered;
        emit EncryptedTokenPublished(id, encryptedAccessToken);
        return true;
    }

    /**
    @dev provider retrieves the temp public key from on-chain
    @param id identifier associated with the access request
    @return the temp public key as string
    */
    function getTempPubKey(bytes32 id) public view onlyProvider(id) isAccessCommitted(id) returns (string) {
        return accessControlRequests[id].tempPubKey;
    }

    /**
    @dev consumer retrieves the encrypted access token from on-chain
    @param id identifier associated with the access request
    @return the encrypted access token as bytes32
    */
    function getEncryptedAccessToken(bytes32 id) public view onlyConsumer(id) isAccessDelivered(id) returns (bytes) {
        return accessControlRequests[id].encryptedAccessToken;
    }

    /**
    @dev provider verifies the signature comes from the consumer
    @param _addr the address of consumer
    @param msgHash the hash of message used for verification
    @param v ECDSA signature is divided into parameters and v is the first part
    @param r ECDSA signature is divided into parameters and r is the second part
    @param s ECDSA signature is divided into parameters and s is the remaining part
    @return valid Boolean indication of if the signature is verified successfully
    */
    function verifySignature(address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public pure returns (bool) {
        return (ecrecover(msgHash, v, r, s) == _addr);
    }

    /**
    @dev provider verify the access token is delivered to consumer and request for payment
    @param id identifier associated with the access request
    @param _addr the address of consumer
    @param msgHash the hash of message used for verification
    @param v ECDSA signature is divided into parameters and v is the first part
    @param r ECDSA signature is divided into parameters and r is the second part
    @param s ECDSA signature is divided into parameters and s is the remaining part
    @return valid Boolean indication of if the signature is verified successfully
    */
    function verifyAccessTokenDelivery(bytes32 id, address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public
    onlyProvider(id) isAccessDelivered(id) returns (bool) {
        // verify signature from consumer
        if (verifySignature(_addr, msgHash, v, r, s)) {
            // send money to provider
            require(market.releasePayment(id), 'Release payment failed.');
            // change status of Request
            accessControlRequests[id].status = AccessStatus.Verified;
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

    /**
    @dev Get status of an access request.
    @param id identifier associated with the access request
    @return integer representing status of `AccessStatus {Requested, Committed, Delivered, Revoked}` as uint8
    */
    function statusOfAccessRequest(bytes32 id) public view returns (uint8) {
        return uint8(accessControlRequests[id].status);
    }

}
```

## Integer Overflow

- Type: Warning
- Contract: OceanAuth
- Function name: `deliverAccessToken(bytes32,bytes)`
- PC address: 6903

### Description

A possible integer overflow exists in the function `deliverAccessToken(bytes32,bytes)`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: OceanAuth.sol:9

### Code

```
contract OceanAuth {

    // ============
    // DATA STRUCTURES:
    // ============
    OceanMarket private market;

    // Sevice level agreement published on immutable storage
    struct AccessAgreement {
        string accessAgreementRef;  // reference link or i.e IPFS hash
        string accessAgreementType; // type such as PDF/DOC/JSON/XML file.
    }

    // consent (initial agreement) provides details about the service
    struct Consent {
        bytes32 resourceId;
        string permissions;
        AccessAgreement accessAgreement;
        bool isAvailable;
        uint256 startDate;
        uint256 expirationDate;
        string discovery;
        uint256 timeout;
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

    enum AccessStatus {Requested, Committed, Delivered, Verified, Revoked}

    // ============
    // modifier:
    // ============
    modifier isAccessRequested(bytes32 id) {
        require(accessControlRequests[id].status == AccessStatus.Requested, 'Status not requested.');
        _;
    }

    modifier isAccessCommitted(bytes32 id) {
        require(accessControlRequests[id].status == AccessStatus.Committed, 'Status not Committed.');
        _;
    }
    modifier isAccessDelivered(bytes32 id) {
        require(market.verifyPaymentReceived(id), 'payment not received');
        require(accessControlRequests[id].status == AccessStatus.Delivered, 'Status not Delivered.');
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

    // ============
    // EVENTS:
    // ============
    /* solium-disable-next-line max-len */
    event AccessConsentRequested(bytes32 _id, address indexed _consumer, address indexed _provider, bytes32 indexed _resourceId, uint _timeout, string _pubKey);
    /* solium-disable-next-line max-len */
    event AccessRequestCommitted(bytes32 indexed _id, uint256 _expirationDate, string _discovery, string _permissions, string _accessAgreementRef);
    event AccessRequestRejected(address indexed _consumer, address indexed _provider, bytes32 indexed _id);
    event AccessRequestRevoked(address indexed _consumer, address indexed _provider, bytes32 indexed _id);
    event EncryptedTokenPublished(bytes32 indexed _id, bytes _encryptedAccessToken);
    event AccessRequestDelivered(address indexed _consumer, address indexed _provider, bytes32 indexed _id);

    /**
    * @dev OceanAuth Constructor
    * @param _marketAddress The deployed contract address of Ocean marketplace
    * Runs only on initial contract creation.
    */
    constructor(address _marketAddress) public {
        require(_marketAddress != address(0), 'Market address cannot be 0x0');
        // instance of Market
        market = OceanMarket(_marketAddress);
        // add auth contract to access list in market contract - function in market contract
        market.addAuthAddress();
    }

    /**
    @dev consumer initiates access request of service
    @param resourceId identifier associated with resource
    @param provider provider address of the requested resource
    @param pubKey the temporary public key generated by consumer in local
    @param timeout the expiration time of access request in seconds
    @return valid Boolean indication of if the access request has been submitted successfully
    */
    function initiateAccessRequest(bytes32 resourceId, address provider, string pubKey, uint256 timeout) public returns (bool) {
        bytes32 id = keccak256(abi.encodePacked(resourceId, msg.sender, provider, pubKey));
        AccessAgreement memory accessAgreement = AccessAgreement(new string(0), new string(0));
        Consent memory consent = Consent(resourceId, new string(0), accessAgreement, false, 0, 0, new string(0), timeout);
        AccessControlRequest memory accessControlRequest = AccessControlRequest(
            msg.sender,
            provider,
            resourceId,
            consent,
            pubKey,
            new bytes(0),
            AccessStatus.Requested
        );

        accessControlRequests[id] = accessControlRequest;
        emit AccessConsentRequested(id, msg.sender, provider, resourceId, timeout, pubKey);
        return true;
    }

    /**
    @dev provider commits the access request of service
    @param id identifier associated with the access request
    @param isAvailable boolean indication of the avaiability of resource
    @param expirationDate the expiration time of access request in seconds
    @param discovery  authorization server configuration in the provider side
    @param permissions comma sparated permissions in one string
    @param accessAgreementRef reference link or i.e IPFS hash
    @param accessAgreementType type such as PDF/DOC/JSON/XML file.
    @return valid Boolean indication of if the access request has been committed successfully
    */
    function commitAccessRequest(
        bytes32 id,
        bool isAvailable,
        uint256 expirationDate,
        string discovery,
        string permissions,
        string accessAgreementRef,
        string accessAgreementType)
    public onlyProvider(id) isAccessRequested(id) returns (bool) {
        /* solium-disable-next-line security/no-block-members */
        if (isAvailable && block.timestamp < expirationDate) {
            accessControlRequests[id].consent.isAvailable = isAvailable;
            accessControlRequests[id].consent.expirationDate = expirationDate;
            /* solium-disable-next-line security/no-block-members */
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
        /* solium-disable-next-line security/no-block-members */
        require(block.timestamp > accessControlRequests[id].consent.timeout, 'Timeout not exceeded.');

        // refund only if consumer had made payment
        if (market.verifyPaymentReceived(id)) {
            require(market.refundPayment(id), 'Refund payment failed.');
        }
        // Always emit this event regardless of payment refund.
        accessControlRequests[id].status = AccessStatus.Revoked;
        emit AccessRequestRevoked(accessControlRequests[id].consumer, accessControlRequests[id].provider, id);
    }

    /**
    @dev provider delivers the access token of service to on-chain
    @param id identifier associated with the access request
    @param encryptedAccessToken the encrypted access token of resource
    @return valid Boolean indication of if the access token has been delivered
    */
    function deliverAccessToken(bytes32 id, bytes encryptedAccessToken) public onlyProvider(id) isAccessCommitted(id) returns (bool) {
        accessControlRequests[id].encryptedAccessToken = encryptedAccessToken;
        accessControlRequests[id].status = AccessStatus.Delivered;
        emit EncryptedTokenPublished(id, encryptedAccessToken);
        return true;
    }

    /**
    @dev provider retrieves the temp public key from on-chain
    @param id identifier associated with the access request
    @return the temp public key as string
    */
    function getTempPubKey(bytes32 id) public view onlyProvider(id) isAccessCommitted(id) returns (string) {
        return accessControlRequests[id].tempPubKey;
    }

    /**
    @dev consumer retrieves the encrypted access token from on-chain
    @param id identifier associated with the access request
    @return the encrypted access token as bytes32
    */
    function getEncryptedAccessToken(bytes32 id) public view onlyConsumer(id) isAccessDelivered(id) returns (bytes) {
        return accessControlRequests[id].encryptedAccessToken;
    }

    /**
    @dev provider verifies the signature comes from the consumer
    @param _addr the address of consumer
    @param msgHash the hash of message used for verification
    @param v ECDSA signature is divided into parameters and v is the first part
    @param r ECDSA signature is divided into parameters and r is the second part
    @param s ECDSA signature is divided into parameters and s is the remaining part
    @return valid Boolean indication of if the signature is verified successfully
    */
    function verifySignature(address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public pure returns (bool) {
        return (ecrecover(msgHash, v, r, s) == _addr);
    }

    /**
    @dev provider verify the access token is delivered to consumer and request for payment
    @param id identifier associated with the access request
    @param _addr the address of consumer
    @param msgHash the hash of message used for verification
    @param v ECDSA signature is divided into parameters and v is the first part
    @param r ECDSA signature is divided into parameters and r is the second part
    @param s ECDSA signature is divided into parameters and s is the remaining part
    @return valid Boolean indication of if the signature is verified successfully
    */
    function verifyAccessTokenDelivery(bytes32 id, address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public
    onlyProvider(id) isAccessDelivered(id) returns (bool) {
        // verify signature from consumer
        if (verifySignature(_addr, msgHash, v, r, s)) {
            // send money to provider
            require(market.releasePayment(id), 'Release payment failed.');
            // change status of Request
            accessControlRequests[id].status = AccessStatus.Verified;
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

    /**
    @dev Get status of an access request.
    @param id identifier associated with the access request
    @return integer representing status of `AccessStatus {Requested, Committed, Delivered, Revoked}` as uint8
    */
    function statusOfAccessRequest(bytes32 id) public view returns (uint8) {
        return uint8(accessControlRequests[id].status);
    }

}
```

## Integer Overflow

- Type: Warning
- Contract: OceanAuth
- Function name: `deliverAccessToken(bytes32,bytes)`
- PC address: 6917

### Description

A possible integer overflow exists in the function `deliverAccessToken(bytes32,bytes)`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: OceanAuth.sol:9

### Code

```
contract OceanAuth {

    // ============
    // DATA STRUCTURES:
    // ============
    OceanMarket private market;

    // Sevice level agreement published on immutable storage
    struct AccessAgreement {
        string accessAgreementRef;  // reference link or i.e IPFS hash
        string accessAgreementType; // type such as PDF/DOC/JSON/XML file.
    }

    // consent (initial agreement) provides details about the service
    struct Consent {
        bytes32 resourceId;
        string permissions;
        AccessAgreement accessAgreement;
        bool isAvailable;
        uint256 startDate;
        uint256 expirationDate;
        string discovery;
        uint256 timeout;
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

    enum AccessStatus {Requested, Committed, Delivered, Verified, Revoked}

    // ============
    // modifier:
    // ============
    modifier isAccessRequested(bytes32 id) {
        require(accessControlRequests[id].status == AccessStatus.Requested, 'Status not requested.');
        _;
    }

    modifier isAccessCommitted(bytes32 id) {
        require(accessControlRequests[id].status == AccessStatus.Committed, 'Status not Committed.');
        _;
    }
    modifier isAccessDelivered(bytes32 id) {
        require(market.verifyPaymentReceived(id), 'payment not received');
        require(accessControlRequests[id].status == AccessStatus.Delivered, 'Status not Delivered.');
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

    // ============
    // EVENTS:
    // ============
    /* solium-disable-next-line max-len */
    event AccessConsentRequested(bytes32 _id, address indexed _consumer, address indexed _provider, bytes32 indexed _resourceId, uint _timeout, string _pubKey);
    /* solium-disable-next-line max-len */
    event AccessRequestCommitted(bytes32 indexed _id, uint256 _expirationDate, string _discovery, string _permissions, string _accessAgreementRef);
    event AccessRequestRejected(address indexed _consumer, address indexed _provider, bytes32 indexed _id);
    event AccessRequestRevoked(address indexed _consumer, address indexed _provider, bytes32 indexed _id);
    event EncryptedTokenPublished(bytes32 indexed _id, bytes _encryptedAccessToken);
    event AccessRequestDelivered(address indexed _consumer, address indexed _provider, bytes32 indexed _id);

    /**
    * @dev OceanAuth Constructor
    * @param _marketAddress The deployed contract address of Ocean marketplace
    * Runs only on initial contract creation.
    */
    constructor(address _marketAddress) public {
        require(_marketAddress != address(0), 'Market address cannot be 0x0');
        // instance of Market
        market = OceanMarket(_marketAddress);
        // add auth contract to access list in market contract - function in market contract
        market.addAuthAddress();
    }

    /**
    @dev consumer initiates access request of service
    @param resourceId identifier associated with resource
    @param provider provider address of the requested resource
    @param pubKey the temporary public key generated by consumer in local
    @param timeout the expiration time of access request in seconds
    @return valid Boolean indication of if the access request has been submitted successfully
    */
    function initiateAccessRequest(bytes32 resourceId, address provider, string pubKey, uint256 timeout) public returns (bool) {
        bytes32 id = keccak256(abi.encodePacked(resourceId, msg.sender, provider, pubKey));
        AccessAgreement memory accessAgreement = AccessAgreement(new string(0), new string(0));
        Consent memory consent = Consent(resourceId, new string(0), accessAgreement, false, 0, 0, new string(0), timeout);
        AccessControlRequest memory accessControlRequest = AccessControlRequest(
            msg.sender,
            provider,
            resourceId,
            consent,
            pubKey,
            new bytes(0),
            AccessStatus.Requested
        );

        accessControlRequests[id] = accessControlRequest;
        emit AccessConsentRequested(id, msg.sender, provider, resourceId, timeout, pubKey);
        return true;
    }

    /**
    @dev provider commits the access request of service
    @param id identifier associated with the access request
    @param isAvailable boolean indication of the avaiability of resource
    @param expirationDate the expiration time of access request in seconds
    @param discovery  authorization server configuration in the provider side
    @param permissions comma sparated permissions in one string
    @param accessAgreementRef reference link or i.e IPFS hash
    @param accessAgreementType type such as PDF/DOC/JSON/XML file.
    @return valid Boolean indication of if the access request has been committed successfully
    */
    function commitAccessRequest(
        bytes32 id,
        bool isAvailable,
        uint256 expirationDate,
        string discovery,
        string permissions,
        string accessAgreementRef,
        string accessAgreementType)
    public onlyProvider(id) isAccessRequested(id) returns (bool) {
        /* solium-disable-next-line security/no-block-members */
        if (isAvailable && block.timestamp < expirationDate) {
            accessControlRequests[id].consent.isAvailable = isAvailable;
            accessControlRequests[id].consent.expirationDate = expirationDate;
            /* solium-disable-next-line security/no-block-members */
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
        /* solium-disable-next-line security/no-block-members */
        require(block.timestamp > accessControlRequests[id].consent.timeout, 'Timeout not exceeded.');

        // refund only if consumer had made payment
        if (market.verifyPaymentReceived(id)) {
            require(market.refundPayment(id), 'Refund payment failed.');
        }
        // Always emit this event regardless of payment refund.
        accessControlRequests[id].status = AccessStatus.Revoked;
        emit AccessRequestRevoked(accessControlRequests[id].consumer, accessControlRequests[id].provider, id);
    }

    /**
    @dev provider delivers the access token of service to on-chain
    @param id identifier associated with the access request
    @param encryptedAccessToken the encrypted access token of resource
    @return valid Boolean indication of if the access token has been delivered
    */
    function deliverAccessToken(bytes32 id, bytes encryptedAccessToken) public onlyProvider(id) isAccessCommitted(id) returns (bool) {
        accessControlRequests[id].encryptedAccessToken = encryptedAccessToken;
        accessControlRequests[id].status = AccessStatus.Delivered;
        emit EncryptedTokenPublished(id, encryptedAccessToken);
        return true;
    }

    /**
    @dev provider retrieves the temp public key from on-chain
    @param id identifier associated with the access request
    @return the temp public key as string
    */
    function getTempPubKey(bytes32 id) public view onlyProvider(id) isAccessCommitted(id) returns (string) {
        return accessControlRequests[id].tempPubKey;
    }

    /**
    @dev consumer retrieves the encrypted access token from on-chain
    @param id identifier associated with the access request
    @return the encrypted access token as bytes32
    */
    function getEncryptedAccessToken(bytes32 id) public view onlyConsumer(id) isAccessDelivered(id) returns (bytes) {
        return accessControlRequests[id].encryptedAccessToken;
    }

    /**
    @dev provider verifies the signature comes from the consumer
    @param _addr the address of consumer
    @param msgHash the hash of message used for verification
    @param v ECDSA signature is divided into parameters and v is the first part
    @param r ECDSA signature is divided into parameters and r is the second part
    @param s ECDSA signature is divided into parameters and s is the remaining part
    @return valid Boolean indication of if the signature is verified successfully
    */
    function verifySignature(address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public pure returns (bool) {
        return (ecrecover(msgHash, v, r, s) == _addr);
    }

    /**
    @dev provider verify the access token is delivered to consumer and request for payment
    @param id identifier associated with the access request
    @param _addr the address of consumer
    @param msgHash the hash of message used for verification
    @param v ECDSA signature is divided into parameters and v is the first part
    @param r ECDSA signature is divided into parameters and r is the second part
    @param s ECDSA signature is divided into parameters and s is the remaining part
    @return valid Boolean indication of if the signature is verified successfully
    */
    function verifyAccessTokenDelivery(bytes32 id, address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public
    onlyProvider(id) isAccessDelivered(id) returns (bool) {
        // verify signature from consumer
        if (verifySignature(_addr, msgHash, v, r, s)) {
            // send money to provider
            require(market.releasePayment(id), 'Release payment failed.');
            // change status of Request
            accessControlRequests[id].status = AccessStatus.Verified;
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

    /**
    @dev Get status of an access request.
    @param id identifier associated with the access request
    @return integer representing status of `AccessStatus {Requested, Committed, Delivered, Revoked}` as uint8
    */
    function statusOfAccessRequest(bytes32 id) public view returns (uint8) {
        return uint8(accessControlRequests[id].status);
    }

}
```

## Integer Overflow

- Type: Warning
- Contract: OceanAuth
- Function name: `deliverAccessToken(bytes32,bytes)`
- PC address: 6939

### Description

A possible integer overflow exists in the function `deliverAccessToken(bytes32,bytes)`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: OceanAuth.sol:9

### Code

```
contract OceanAuth {

    // ============
    // DATA STRUCTURES:
    // ============
    OceanMarket private market;

    // Sevice level agreement published on immutable storage
    struct AccessAgreement {
        string accessAgreementRef;  // reference link or i.e IPFS hash
        string accessAgreementType; // type such as PDF/DOC/JSON/XML file.
    }

    // consent (initial agreement) provides details about the service
    struct Consent {
        bytes32 resourceId;
        string permissions;
        AccessAgreement accessAgreement;
        bool isAvailable;
        uint256 startDate;
        uint256 expirationDate;
        string discovery;
        uint256 timeout;
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

    enum AccessStatus {Requested, Committed, Delivered, Verified, Revoked}

    // ============
    // modifier:
    // ============
    modifier isAccessRequested(bytes32 id) {
        require(accessControlRequests[id].status == AccessStatus.Requested, 'Status not requested.');
        _;
    }

    modifier isAccessCommitted(bytes32 id) {
        require(accessControlRequests[id].status == AccessStatus.Committed, 'Status not Committed.');
        _;
    }
    modifier isAccessDelivered(bytes32 id) {
        require(market.verifyPaymentReceived(id), 'payment not received');
        require(accessControlRequests[id].status == AccessStatus.Delivered, 'Status not Delivered.');
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

    // ============
    // EVENTS:
    // ============
    /* solium-disable-next-line max-len */
    event AccessConsentRequested(bytes32 _id, address indexed _consumer, address indexed _provider, bytes32 indexed _resourceId, uint _timeout, string _pubKey);
    /* solium-disable-next-line max-len */
    event AccessRequestCommitted(bytes32 indexed _id, uint256 _expirationDate, string _discovery, string _permissions, string _accessAgreementRef);
    event AccessRequestRejected(address indexed _consumer, address indexed _provider, bytes32 indexed _id);
    event AccessRequestRevoked(address indexed _consumer, address indexed _provider, bytes32 indexed _id);
    event EncryptedTokenPublished(bytes32 indexed _id, bytes _encryptedAccessToken);
    event AccessRequestDelivered(address indexed _consumer, address indexed _provider, bytes32 indexed _id);

    /**
    * @dev OceanAuth Constructor
    * @param _marketAddress The deployed contract address of Ocean marketplace
    * Runs only on initial contract creation.
    */
    constructor(address _marketAddress) public {
        require(_marketAddress != address(0), 'Market address cannot be 0x0');
        // instance of Market
        market = OceanMarket(_marketAddress);
        // add auth contract to access list in market contract - function in market contract
        market.addAuthAddress();
    }

    /**
    @dev consumer initiates access request of service
    @param resourceId identifier associated with resource
    @param provider provider address of the requested resource
    @param pubKey the temporary public key generated by consumer in local
    @param timeout the expiration time of access request in seconds
    @return valid Boolean indication of if the access request has been submitted successfully
    */
    function initiateAccessRequest(bytes32 resourceId, address provider, string pubKey, uint256 timeout) public returns (bool) {
        bytes32 id = keccak256(abi.encodePacked(resourceId, msg.sender, provider, pubKey));
        AccessAgreement memory accessAgreement = AccessAgreement(new string(0), new string(0));
        Consent memory consent = Consent(resourceId, new string(0), accessAgreement, false, 0, 0, new string(0), timeout);
        AccessControlRequest memory accessControlRequest = AccessControlRequest(
            msg.sender,
            provider,
            resourceId,
            consent,
            pubKey,
            new bytes(0),
            AccessStatus.Requested
        );

        accessControlRequests[id] = accessControlRequest;
        emit AccessConsentRequested(id, msg.sender, provider, resourceId, timeout, pubKey);
        return true;
    }

    /**
    @dev provider commits the access request of service
    @param id identifier associated with the access request
    @param isAvailable boolean indication of the avaiability of resource
    @param expirationDate the expiration time of access request in seconds
    @param discovery  authorization server configuration in the provider side
    @param permissions comma sparated permissions in one string
    @param accessAgreementRef reference link or i.e IPFS hash
    @param accessAgreementType type such as PDF/DOC/JSON/XML file.
    @return valid Boolean indication of if the access request has been committed successfully
    */
    function commitAccessRequest(
        bytes32 id,
        bool isAvailable,
        uint256 expirationDate,
        string discovery,
        string permissions,
        string accessAgreementRef,
        string accessAgreementType)
    public onlyProvider(id) isAccessRequested(id) returns (bool) {
        /* solium-disable-next-line security/no-block-members */
        if (isAvailable && block.timestamp < expirationDate) {
            accessControlRequests[id].consent.isAvailable = isAvailable;
            accessControlRequests[id].consent.expirationDate = expirationDate;
            /* solium-disable-next-line security/no-block-members */
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
        /* solium-disable-next-line security/no-block-members */
        require(block.timestamp > accessControlRequests[id].consent.timeout, 'Timeout not exceeded.');

        // refund only if consumer had made payment
        if (market.verifyPaymentReceived(id)) {
            require(market.refundPayment(id), 'Refund payment failed.');
        }
        // Always emit this event regardless of payment refund.
        accessControlRequests[id].status = AccessStatus.Revoked;
        emit AccessRequestRevoked(accessControlRequests[id].consumer, accessControlRequests[id].provider, id);
    }

    /**
    @dev provider delivers the access token of service to on-chain
    @param id identifier associated with the access request
    @param encryptedAccessToken the encrypted access token of resource
    @return valid Boolean indication of if the access token has been delivered
    */
    function deliverAccessToken(bytes32 id, bytes encryptedAccessToken) public onlyProvider(id) isAccessCommitted(id) returns (bool) {
        accessControlRequests[id].encryptedAccessToken = encryptedAccessToken;
        accessControlRequests[id].status = AccessStatus.Delivered;
        emit EncryptedTokenPublished(id, encryptedAccessToken);
        return true;
    }

    /**
    @dev provider retrieves the temp public key from on-chain
    @param id identifier associated with the access request
    @return the temp public key as string
    */
    function getTempPubKey(bytes32 id) public view onlyProvider(id) isAccessCommitted(id) returns (string) {
        return accessControlRequests[id].tempPubKey;
    }

    /**
    @dev consumer retrieves the encrypted access token from on-chain
    @param id identifier associated with the access request
    @return the encrypted access token as bytes32
    */
    function getEncryptedAccessToken(bytes32 id) public view onlyConsumer(id) isAccessDelivered(id) returns (bytes) {
        return accessControlRequests[id].encryptedAccessToken;
    }

    /**
    @dev provider verifies the signature comes from the consumer
    @param _addr the address of consumer
    @param msgHash the hash of message used for verification
    @param v ECDSA signature is divided into parameters and v is the first part
    @param r ECDSA signature is divided into parameters and r is the second part
    @param s ECDSA signature is divided into parameters and s is the remaining part
    @return valid Boolean indication of if the signature is verified successfully
    */
    function verifySignature(address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public pure returns (bool) {
        return (ecrecover(msgHash, v, r, s) == _addr);
    }

    /**
    @dev provider verify the access token is delivered to consumer and request for payment
    @param id identifier associated with the access request
    @param _addr the address of consumer
    @param msgHash the hash of message used for verification
    @param v ECDSA signature is divided into parameters and v is the first part
    @param r ECDSA signature is divided into parameters and r is the second part
    @param s ECDSA signature is divided into parameters and s is the remaining part
    @return valid Boolean indication of if the signature is verified successfully
    */
    function verifyAccessTokenDelivery(bytes32 id, address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public
    onlyProvider(id) isAccessDelivered(id) returns (bool) {
        // verify signature from consumer
        if (verifySignature(_addr, msgHash, v, r, s)) {
            // send money to provider
            require(market.releasePayment(id), 'Release payment failed.');
            // change status of Request
            accessControlRequests[id].status = AccessStatus.Verified;
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

    /**
    @dev Get status of an access request.
    @param id identifier associated with the access request
    @return integer representing status of `AccessStatus {Requested, Committed, Delivered, Revoked}` as uint8
    */
    function statusOfAccessRequest(bytes32 id) public view returns (uint8) {
        return uint8(accessControlRequests[id].status);
    }

}
```

# Analysis result for SafeMath

No issues found.
# Analysis results for BasicToken.sol

## Integer Overflow

- Type: Warning
- Contract: BasicToken
- Function name: `transfer(address,uint256)`
- PC address: 580

### Description

A possible integer overflow exists in the function `transfer(address,uint256)`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: BasicToken.sol:27

### Code

```
  ret
```

## Exception state

- Type: Informational
- Contract: BasicToken
- Function name: `transfer(address,uint256)`
- PC address: 589

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: BasicToken.sol:28

### Code

```
    }

    /**
```

# Analysis results for StandardToken.sol

## Integer Overflow

- Type: Warning
- Contract: StandardToken
- Function name: `transferFrom(address,address,uint256)`
- PC address: 1710

### Description

A possible integer overflow exists in the function `transferFrom(address,address,uint256)`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: StandardToken.sol:25

### Code

```
addre
```

## Exception state

- Type: Informational
- Contract: StandardToken
- Function name: `transferFrom(address,address,uint256)`
- PC address: 1719

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: StandardToken.sol:25

### Code

```
nt256 _value) 
```

# Analysis results for EIP20.sol

## Integer Overflow

- Type: Warning
- Contract: EIP20
- Function name: `fallback`
- PC address: 723

### Description

A possible integer overflow exists in the function `fallback`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: EIP20.sol:20

### Code

```
string public name
```

## Integer Overflow

- Type: Warning
- Contract: EIP20
- Function name: `transferFrom(address,address,uint256)`
- PC address: 1054

### Description

A possible integer overflow exists in the function `transferFrom(address,address,uint256)`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: EIP20.sol:48

### Code

```
balances[_to] += _value
```

## Integer Overflow

- Type: Warning
- Contract: EIP20
- Function name: `symbol()`
- PC address: 1316

### Description

A possible integer overflow exists in the function `symbol()`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: EIP20.sol:22

### Code

```
string public symbol
```

## Integer Overflow

- Type: Warning
- Contract: EIP20
- Function name: `transfer(address,uint256)`
- PC address: 1456

### Description

A possible integer overflow exists in the function `transfer(address,uint256)`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: EIP20.sol:40

### Code

```
balances[_to] += _value
```

# Analysis results for OceanMarket.sol

## Integer Overflow

- Type: Warning
- Contract: OceanMarket
- Function name: `generateId(bytes)`
- PC address: 340

### Description

A possible integer overflow exists in the function `generateId(bytes)`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: OceanMarket.sol:245

### Code

```
function generateId(string contents) public pure returns (bytes32) {
        // Generate the hash of input string
        return bytes32(keccak256(abi.encodePacked(contents)));
    }
```

## Message call to external contract

- Type: Informational
- Contract: OceanMarket
- Function name: `fallback`
- PC address: 1003

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanMarket.sol:222

### Code

```
tcr.isWhitelisted(listing)
```

## Exception state

- Type: Informational
- Contract: OceanMarket
- Function name: `verifyPaymentReceived(bytes32)`
- PC address: 1333

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: OceanMarket.sol:165

### Code

```
mPayments[_paymentId].state == PaymentState.Locked
```

## Message call to external contract

- Type: Informational
- Contract: OceanMarket
- Function name: `sendPayment(bytes32,address,uint256,uint256)`
- PC address: 1856

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanMarket.sol:127

### Code

```
mToken.transferFrom(msg.sender, address(this), _amount)
```

## State change after external call

- Type: Warning
- Contract: OceanMarket
- Function name: `sendPayment(bytes32,address,uint256,uint256)`
- PC address: 2090

### Description

The contract account state is changed after an external call. Consider that the called contract could re-enter the function before this state change takes place. This can lead to business logic vulnerabilities.
In file: OceanMarket.sol:129

### Code

```
mPayments[_paymentId] = Payment(msg.sender, _receiver, PaymentState.Locked, _amount, block.timestamp, _expire)
```

## State change after external call

- Type: Warning
- Contract: OceanMarket
- Function name: `sendPayment(bytes32,address,uint256,uint256)`
- PC address: 2111

### Description

The contract account state is changed after an external call. Consider that the called contract could re-enter the function before this state change takes place. This can lead to business logic vulnerabilities.
In file: OceanMarket.sol:129

### Code

```
mPayments[_paymentId] = Payment(msg.sender, _receiver, PaymentState.Locked, _amount, block.timestamp, _expire)
```

## State change after external call

- Type: Warning
- Contract: OceanMarket
- Function name: `sendPayment(bytes32,address,uint256,uint256)`
- PC address: 2165

### Description

The contract account state is changed after an external call. Consider that the called contract could re-enter the function before this state change takes place. This can lead to business logic vulnerabilities.
In file: OceanMarket.sol:129

### Code

```
mPayments[_paymentId] = Payment(msg.sender, _receiver, PaymentState.Locked, _amount, block.timestamp, _expire)
```

## State change after external call

- Type: Warning
- Contract: OceanMarket
- Function name: `sendPayment(bytes32,address,uint256,uint256)`
- PC address: 2176

### Description

The contract account state is changed after an external call. Consider that the called contract could re-enter the function before this state change takes place. This can lead to business logic vulnerabilities.
In file: OceanMarket.sol:129

### Code

```
mPayments[_paymentId] = Payment(msg.sender, _receiver, PaymentState.Locked, _amount, block.timestamp, _expire)
```

## State change after external call

- Type: Warning
- Contract: OceanMarket
- Function name: `sendPayment(bytes32,address,uint256,uint256)`
- PC address: 2186

### Description

The contract account state is changed after an external call. Consider that the called contract could re-enter the function before this state change takes place. This can lead to business logic vulnerabilities.
In file: OceanMarket.sol:129

### Code

```
mPayments[_paymentId] = Payment(msg.sender, _receiver, PaymentState.Locked, _amount, block.timestamp, _expire)
```

## State change after external call

- Type: Warning
- Contract: OceanMarket
- Function name: `sendPayment(bytes32,address,uint256,uint256)`
- PC address: 2198

### Description

The contract account state is changed after an external call. Consider that the called contract could re-enter the function before this state change takes place. This can lead to business logic vulnerabilities.
In file: OceanMarket.sol:129

### Code

```
mPayments[_paymentId] = Payment(msg.sender, _receiver, PaymentState.Locked, _amount, block.timestamp, _expire)
```

## Exception state

- Type: Informational
- Contract: OceanMarket
- Function name: `releasePayment(bytes32)`
- PC address: 2326

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: OceanMarket.sol:73

### Code

```
mPayments[_paymentId].state == PaymentState.Locked
```

## Message call to external contract

- Type: Informational
- Contract: OceanMarket
- Function name: `releasePayment(bytes32)`
- PC address: 2698

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanMarket.sol:142

### Code

```
mToken.transfer(mPayments[_paymentId].receiver, mPayments[_paymentId].amount)
```

## Exception state

- Type: Informational
- Contract: OceanMarket
- Function name: `refundPayment(bytes32)`
- PC address: 3000

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: OceanMarket.sol:73

### Code

```
mPayments[_paymentId].state == PaymentState.Locked
```

## Message call to external contract

- Type: Informational
- Contract: OceanMarket
- Function name: `refundPayment(bytes32)`
- PC address: 3389

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanMarket.sol:154

### Code

```
mToken.transfer(mPayments[_paymentId].sender, mPayments[_paymentId].amount)
```

## Integer Overflow

- Type: Warning
- Contract: OceanMarket
- Function name: `requestTokens(uint256)`
- PC address: 3667

### Description

A possible integer overflow exists in the function `requestTokens(uint256)`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: OceanMarket.sol:178

### Code

```
tokenRequest[msg.sender] + minPeriod
```

## Message call to external contract

- Type: Informational
- Contract: OceanMarket
- Function name: `checkListingStatus(bytes32)`
- PC address: 4443

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanMarket.sol:212

### Code

```
tcr.isWhitelisted(listing)
```

# Analysis result for Ownable

No issues found.
# Analysis results for OceanToken.sol

## Integer Overflow

- Type: Warning
- Contract: OceanToken
- Function name: `transferFrom(address,address,uint256)`
- PC address: 2738

### Description

A possible integer overflow exists in the function `transferFrom(address,address,uint256)`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: OceanToken.sol:26

### Code

```
    /
```

## Exception state

- Type: Informational
- Contract: OceanToken
- Function name: `transferFrom(address,address,uint256)`
- PC address: 2747

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: OceanToken.sol:26

### Code

```
to receive TOK
```


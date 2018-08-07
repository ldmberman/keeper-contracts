# Integration of TCRs, CPM and Ocean Tokens with Solidity

```
name: Integration of TCRs, CPM, and Ocean tokens with Solidity
type: development
status: initial draft
editor: Fang Gong <fang@oceanprotocol.com>
collaborator: Aitor Argomaniz <aitor@oceanprotocol.com>
date: 08/06/2018
```

## Further Documentation

* [TCR Owner's Manual](owners_manual.md)

## Objective

In this project, we put following modules together:

* **TCRs**: users create challenges and resolve them through voting to maintain registries;
* **Ocean Tokens**: the intrinsic tokens circulated inside Ocean network, which is used in the voting of TCRs;
* **Curated Proofs Market**: the core marketplace where people can transact with each other and curate assets through staking with Ocean tokens.


## Public Interface

The project exposes the following public interfaces:

### Token Curated Registry (OceanRegistry.sol)

```solidity
//Allows a user to start an application. Takes tokens from user and sets apply stage end time.
function apply(bytes32 _listingHash, uint _amount, string _data);

// Allows the owner of a listingHash to increase their unstaked deposit.
function deposit(bytes32 _listingHash, uint _amount);

//Allows the owner of a listingHash to decrease their unstaked deposit.
function withdraw(bytes32 _listingHash, uint _amount);

// Allows the owner of a listingHash to remove the listingHash from the whitelist
function exit(bytes32 _listingHash);

// Starts a poll for a listingHash which is either in the apply stage or already in the whitelist.
function challenge(bytes32 _listingHash, string _data);

// Updates a listingHash’s status from ‘application’ to ‘listing’ or resolves a challenge if one exists.
function updateStatus(bytes32 _listingHash);

// Called by a voter to claim their reward for each completed vote.
function claimReward(uint _challengeID, uint _salt);

// Calculates the provided voter’s token reward for the given poll.
function voterReward(address _voter, uint _challengeID, uint _salt);

// Determines whether the given listingHash be whitelisted.
function canBeWhitelisted(bytes32 _listingHash);

// Returns true if the provided listingHash is whitelisted
function isWhitelisted(bytes32 _listingHash);

// Determines the number of tokens awarded to the winning party in a challenge.
   function determineReward(uint _challengeID);
```

### Marketplace (OceanMarket.sol)

```solidity
// Register data assets
function register(bytes32 assetId, uint256 price) public returns (bool success);

// consumer can make payment
function sendPayment(bytes32 _paymentId, address _receiver, uint256 _amount, uint256 _expire) public returns (bool);

// release fund to provider - must be called by OceanAuth contract
function releasePayment(bytes32 _paymentId) public isLocked(_paymentId) returns (bool);

// refund payment - must be called by OceanAuth contract
function refundPayment(bytes32 _paymentId) public isLocked(_paymentId) returns (bool);

// verify the payment is received
function verifyPaymentReceived(bytes32 _paymentId) public view returns (bool);

// Generate Unique Id for asset using input string parameter
function generateStr2Id(string contents) public pure returns (bytes32);

// Generate Unique Id for asset using input bytes parameter
function generateBytes2Id(bytes contents) public pure returns (bytes32);

// Market checks the TCR voting results
function checkListingStatus(bytes32 listing) public view returns(bool);

// Market changes the status of TCR according to voting result
function changeListingStatus(bytes32 listing, bytes32 assetId) public returns(bool);
```


### On-Chain Authorization (OceanAuth.sol)

```solidity
// consumer request access to resource
function initiateAccessRequest(bytes32 resourceId, address provider, string pubKey, uint256 timeout) public returns (bool);

// provider commit the access request
function commitAccessRequest(bytes32 id, bool isAvailable, uint256 expirationDate, string discovery, string permissions, string accessAgreementRef, string accessAgreementType) public onlyProvider(id) isAccessRequested(id) returns (bool);

// consumer can cancel the access request
function cancelAccessRequest(bytes32 id) public isAccessCommitted(id) onlyConsumer(id);

// provider deliver the access token
function deliverAccessToken(bytes32 id, bytes encryptedAccessToken) public onlyProvider(id) isAccessCommitted(id) returns (bool);

// provider verify the delivery of JWT access token
function verifyAccessTokenDelivery(bytes32 id, address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public
onlyProvider(id) isAccessComitted(id) returns (bool);
```

### Query functions

```solidity
// provider query the temp public key
function getTempPubKey(bytes32 id) public view onlyProvider(id) isAccessCommitted(id) returns (string);

// consumer query the encrypted access token
function getEncryptedAccessToken(bytes32 id) public view onlyConsumer(id) isAccessCommitted(id) returns (bytes);

// provider uses this function to verify the signature comes from the consumer
function isSigned(address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public pure returns (bool);

// verify the status of access request
function verifyCommitted(bytes32 id, uint256 status) public view returns (bool);

// Return true or false if an Asset is active given the assetId
function checkAsset(bytes32 assetId) public view returns (bool);

// Retrieve the price of asset
function getAssetPrice(bytes32 assetId) public view returns (uint256);
```

###  Events

```solidity
// OceanMarket Events
event AssetRegistered(bytes32 indexed _assetId, address indexed _owner);
event PaymentReceived(bytes32 indexed _paymentId, address indexed _receiver, uint256 _amount, uint256 _expire);
event PaymentReleased(bytes32 indexed _paymentId, address indexed _receiver);
event PaymentRefunded(bytes32 indexed _paymentId, address indexed _sender);

// OceanAuth Events
event AccessConsentRequested(bytes32 _id, address _consumer, address _provider, bytes32 _resourceId, uint _timeout, string _pubKey);
event AccessRequestCommitted(bytes32 _id, uint256 _expirationDate, string _discovery, string _permissions, string _accessAgreementRef);
event AccessRequestRejected(address _consumer, address _provider, bytes32 _id);
event AccessRequestRevoked(address _consumer, address _provider, bytes32 _id);
event EncryptedTokenPublished(bytes32 _id, bytes _encryptedAccessToken);
event AccessRequestDelivered(address _consumer, address _provider, bytes32 _id);
```

## File Structure

There are several folders and each includes solidity source files for each module:

<img src="img/files.jpg" width="250" />

* **auth**: OceanAuth contract for authorization;
* **plcrvoting**: Partial Lock Commit Reveal Voting System;
* **tcr**: the TCRs related files;
* **token**: Ocean tokens based on ERC20 standard;
* **zeppelin**: the library files from OpenZeppelin;
* **Oceanmarket.sol**: curated proofs market (*on-going work*);
* **Migrations.sol**: default contract for migration.

## Architecture of Solidity Market Contract

* [First draft of UML class diagram](files/Smart-Contract-UML-class-diagram.pdf)

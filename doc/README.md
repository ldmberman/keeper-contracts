# Integration of TCRs, CPM and Ocean Tokens with Solidity

```
name: Integration of TCRs, CPM, and Ocean tokens with Solidity
type: development
status: initial draft
editor: Fang Gong <fang@oceanprotocol.com>
collaborator: Aitor Argomaniz <aitor@oceanprotocol.com>
date: 06/01/2018
```

## Further Documentation

* [TCR Owner's Manual](owners_manual.md)
* [On-chain Authorization Manual](authorization.md)

## Objective

In this project, we put following modules together:

* **TCRs**: users create challenges and resolve them through voting to maintain registries;
* **Ocean Tokens**: the intrinsic tokens circulated inside Ocean network, which is used in the voting of TCRs;
* **Curated Proofs Market**: the core marketplace where people can transact with each other and curate assets through staking with Ocean tokens.


## Public Interface

The project exposes the following public interfaces:

### Curation Market

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

### Marketplace

```solidity
// Register provider and assets （upload by changing uploadBits）
function register(bytes32 assetId, uint256 price) public returns (bool success);

// consumer can make payment
function sendPayment(bytes32 _paymentId, address _receiver, uint256 _amount, uint256 _expire) public validAddress(msg.sender) returns (bool);

// release fund to provider
function releasePayment(bytes32 _paymentId) public isLocked(_paymentId) returns (bool);

// refund payment
function refundPayment(bytes32 _paymentId) public isLocked(_paymentId) returns (bool);

// verify the payment
function verifyPayment(bytes32 _paymentId) public view returns(bool);

// Generate Unique Id for asset using input string parameter
function generateStr2Id(string contents) public pure returns (bytes32);

// Generate Unique Id for asset using input bytes parameter
function generateBytes2Id(bytes contents) public pure returns (bytes32);
```


### On-Chain Authorization

```solidity
// consumer request access to resource
function initiateAccessRequest(bytes32 id, bytes32 resourceId, address provider, string pubKey, uint256 timeout) public returns (bool) {;

// provider commit the access request
function commitAccessRequest(bytes32 id, bool available, uint256 expire, string discovery, string permissions, string slaLink, string slaType)
public onlyProvider(id) isAccessRequested(id) returns (bool);

// provider deliver the access token
function deliverAccessToken(bytes32 id, string encryptedJWT) public onlyProvider(id) isAccessComitted(id) returns (bool);

// provider get the temp public key
function getTempPubKey(bytes32 id) public view onlyProvider(id) isAccessComitted(id) returns (string);

// consumer get the encrypted JWT
function getEncJWT(bytes32 id) public view onlyConsumer(id) isAccessComitted(id) returns (string);

// provider verify the signature coming from consumer
function isSigned(address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public view returns (bool);

// provider verify the delivery of JWT access token
function verifyAccessTokenDelivery(bytes32 id, address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public
onlyProvider(id) isAccessComitted(id) returns (bool);
```

### Query functions

```solidity
// provider query the temp public key of order
function queryTempKey(bytes32 orderId) public view returns (string);

// consumer query the encrypted access token of order
function queryToken(bytes32 orderId) public view returns (string);

// Return true if assetId is unique; otherwise, return false
function checkUniqueId(bytes32 assetId) public view returns (bool);

// Return true if assetId is valid for registered asset
function checkValidId(bytes32 assetId) public view returns (bool);

// Return the number of drops associated to the message.sender to an Asset
function dropsBalance(bytes32 assetId) public view returns (uint256);

// Return true or false if an Asset is active given the assetId
function checkAsset(bytes32 assetId) public view returns (bool);

// Retrieve the msg.sender Provider token balance
function tokenBalance() public view returns (uint256);
```

###  Events

```solidity
// Asset Events
event AssetRegistered(bytes32 indexed _assetId, address indexed _owner);
event PaymentReceived(bytes32 indexed _paymentId, address indexed _receiver, uint256 _amount, uint256 _expire);
event PaymentReleased(bytes32 indexed _paymentId, address indexed _receiver);
event PaymentRefunded(bytes32 indexed _paymentId, address indexed _sender);
event TempKeyCreated(bytes32 indexed _orderId, string _tempPublicKey, address indexed _consumer);
event TokenCreated(bytes32 indexed _orderId, address indexed _provider);

// Token Events
event TokenWithdraw(address indexed _requester, uint256 amount);
event TokenBuyDrops(address indexed _requester, bytes32 indexed _assetId, uint256 _ocn, uint256 _drops);
event TokenSellDrops(address indexed _requester, bytes32 indexed _assetId, uint256 _ocn, uint256 _drops);

// Authorization
event RequestAccessConsent(bytes32 _id, address _consumer, address _provider, bytes32 _resource, uint _timeout, string _pubKey);
event CommitConsent(bytes32 _id, uint256 _expire, string _discovery, string _permissions, string slaLink);
event RefundPayment(address _consumer, address _provider, bytes32 _id);
event PublishEncryptedToken(bytes32 _id, string encJWT);
event ReleasePayment(address _consumer, address _provider, bytes32 _id);
```

## File Structure

There are several folders and each includes solidity source files for each module:

<img src="img/files.jpg" width="250" />

* **bondingCurve**: it caculates the bonding curve values when users purchase drops or sell drops in the marketplace;
* **plcrvoting**: Partial Lock Commit Reveal Voting System;
* **tcr**: the TCRs related files;
* **token**: Ocean tokens based on ERC20 standard;
* **zeppelin**: the library files from OpenZeppelin;
* **market.sol**: curated proofs market (*on-going work*)

## Architecture of Modules

The dependency between different modules are illustrated as below:

<img src="img/structure.jpg" width="800" />

* Marketplace (Market.sol) sends listing hash to TCRs (Registry.sol) so that to create challenges.
* Users can use Ocean Tokens (OceanToken.sol) to vote for or against (PLCRVoting.sol).
* Voting is configured with the parameters (Parameterizer.sol).
* Marketplace uses bonding curve (BancorFormula.sol) to determine the price of drops.
* BancorFormula calculates the power function (Power.sol).
* TCRs (Registry.sol) send the voting result back to Marketplace (Market.sol).

## Architecture of Solidity Market Contract

* [First draft of UML class diagram](files/Smart-Contract-UML-class-diagram.pdf)

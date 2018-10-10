pragma solidity 0.4.25;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

import './token/OceanToken.sol';
import './tcr/OceanRegistry.sol';

/**
@title Ocean Protocol Marketplace Contract
@author Team: Fang Gong, Samer Sallam, Ahmed Ali, Sebastian Gerske
*/

contract OceanMarket is Ownable {

    using SafeMath for uint256;
    using SafeMath for uint;

    // ============
    // DATA STRUCTURES:
    // ============
    struct Asset {
        address owner;  // owner of the Asset
        uint256 price;  // price of asset
        bool active;    // status of asset
    }

    mapping(bytes32 => Asset) private mAssets;           // mapping assetId to Asset struct

    struct Payment {
        address sender;             // payment sender
        address receiver;           // provider or anyone (set by the sender of funds)
        PaymentState state;         // payment state
        uint256 amount;             // amount of tokens to be transferred
        uint256 date;               // timestamp of the payment event (in sec.)
        uint256 expiration;         // consumer may request refund after expiration timestamp (in sec.)
        bool paused;                // pause the process of payment if dispute raised
    }
    enum PaymentState {Locked, Released, Refunded}
    mapping(bytes32 => Payment) private mPayments;  // mapping from id to associated payment struct

    // limit period for reques of tokens
    mapping(address => uint256) private tokenRequest; // mapping from address to last time of request
    uint256 maxAmount = 10000 * 10 ** 18;         // max amount of tokens user can get for each request
    uint256 minPeriod = 0;                        // min amount of time to wait before request token again

    // limit access to refund payment
    address private authAddress;
    address private disputeAddress;

    // marketplace global variables
    OceanToken  public  mToken;

    // todo: rename to registry
    // tcr global variable
    OceanRegistry  public  tcr;

    // ============
    // EVENTS:
    // ============
    event AssetRegistered(bytes32 indexed _assetId, address indexed _owner);
    event FrequentTokenRequest(address indexed _requester, uint256 _minPeriod);
    event LimitTokenRequest(address indexed _requester, uint256 _amount, uint256 _maxAmount);
    event PaymentReceived(bytes32 indexed _paymentId, address indexed _receiver, uint256 _amount, uint256 _expire);
    event PaymentReleased(bytes32 indexed _paymentId, address indexed _receiver);
    event PaymentRefunded(bytes32 indexed _paymentId, address indexed _sender);

    // ============
    // modifier:
    // ============
    modifier validAddress(address sender) {
        require(sender != address(0x0), 'Sender address is 0x0.');
        _;
    }

    modifier isLocked(bytes32 _paymentId) {
        require(mPayments[_paymentId].state == PaymentState.Locked, 'State is not Locked');
        _;
    }

    modifier isAuthContract() {
        require(
            msg.sender == authAddress || msg.sender == address(this) || msg.sender == disputeAddress, 'Sender is not an authorized contract.'
        );
        _;
    }

    /**
    * @dev OceanMarket Constructor
    * @param _tokenAddress The deployed contract address of OceanToken
    * @param _registryAddress The deployed contract address of OceanRegistry
    * Runs only on initial contract creation.
    */
    constructor(address _tokenAddress, address _registryAddress) public {
        require(_tokenAddress != address(0x0), 'Token address is 0x0.');
        // instantiate Ocean token contract
        mToken = OceanToken(_tokenAddress);
        // todo: rename to registry
        // instance of registry
        tcr = OceanRegistry(_registryAddress);
        // set the token receiver to be marketplace
        mToken.setReceiver(address(this));
        // create market contract instance in tcr
        tcr.setMarketInstance(address(this));
    }

    /**
    * @dev provider register the new asset
    * @param assetId the integer identifier of new asset
    * @param price the integer representing price of new asset
    * @return valid Boolean indication of registration of new asset
    */
    function register(bytes32 assetId, uint256 price) public validAddress(msg.sender) returns (bool success) {
        require(mAssets[assetId].owner == address(0), 'Owner address is not 0x0.');
        mAssets[assetId] = Asset(msg.sender, price, false);
        mAssets[assetId].active = true;

        emit AssetRegistered(assetId, msg.sender);
        return true;
    }

    /**
    * @dev sender tranfer payment to OceanMarket contract
    * @param _paymentId the integer identifier of payment
    * @param _receiver the address of receiver
    * @param _amount the payment amount
    * @param _expire the expiration time in seconds
    * @return valid Boolean indication of payment is transferred
    */
    function sendPayment(
        bytes32 _paymentId,
        address _receiver,
        uint256 _amount,
        uint256 _expire) public validAddress(msg.sender) returns (bool) {
        // consumer make payment to Market contract
        require(mToken.transferFrom(msg.sender, address(this), _amount), 'Token transferFrom failed.');
        /* solium-disable-next-line security/no-block-members */
        mPayments[_paymentId] = Payment(msg.sender, _receiver, PaymentState.Locked, _amount, block.timestamp, _expire, false);
        emit PaymentReceived(_paymentId, _receiver, _amount, _expire);
        return true;
    }

    /**
    * @dev dispute resolution calls this function to pause payment
    * @param _paymentId the integer identifier of payment (the same as dispute Id and service agreement Id)
    */
    function pausePayment(bytes32 _paymentId) public isLocked(_paymentId) isAuthContract() {
        mPayments[_paymentId].paused = true;
    }

    /**
    * @dev dispute resolution calls this function to process payment
    * @param _paymentId the integer identifier of payment (the same as dispute Id and service agreement Id)
    * @param _release the boolean value indication of release payment
    * @param _refund the boolean value indication of refund payment
    */
    function processPayment(bytes32 _paymentId, bool _release, bool _refund) public isLocked(_paymentId) isAuthContract() {
        // unpause the payment
        mPayments[_paymentId].paused = false;
        // process payment
        if (_release == true && _refund == false) {
            releasePayment(_paymentId);
        } else if (_release == false && _refund == true) {
            refundPayment(_paymentId);
        }
    }


    /**
    * @dev the consumer release payment to receiver
    * @param _paymentId the integer identifier of payment
    * @return valid Boolean indication of payment is released
    */
    function releasePayment(bytes32 _paymentId) public isLocked(_paymentId) isAuthContract() returns (bool) {
        // payment must not be paused
        require(mPayments[_paymentId].paused == false, 'Payment is paused');
        // update state to avoid re-entry attack
        mPayments[_paymentId].state = PaymentState.Released;
        require(mToken.transfer(mPayments[_paymentId].receiver, mPayments[_paymentId].amount), 'Token transfer failed.');
        emit PaymentReleased(_paymentId, mPayments[_paymentId].receiver);
        return true;
    }

    /**
    * @dev the consumer get refunded payment from OceanMarket contract
    * @param _paymentId the integer identifier of payment
    * @return valid Boolean indication of payment is refunded
    */
    function refundPayment(bytes32 _paymentId) public isLocked(_paymentId) isAuthContract() returns (bool) {
        // payment must not be paused
        require(mPayments[_paymentId].paused == false, 'Payment is paused');
        // refund payment to consumer
        mPayments[_paymentId].state = PaymentState.Refunded;
        require(mToken.transfer(mPayments[_paymentId].sender, mPayments[_paymentId].amount), 'Token transfer failed.');
        emit PaymentRefunded(_paymentId, mPayments[_paymentId].sender);
        return true;
    }

    /**
    * @dev verify the payment of consumer is received by OceanMarket
    * @param _paymentId the integer identifier of payment
    * @return valid Boolean indication of payment is received
    */
    function verifyPaymentReceived(bytes32 _paymentId) public view returns (bool) {
        if (mPayments[_paymentId].state == PaymentState.Locked) {
            return true;
        }
        return false;
    }

    /**
    * @dev user can request some tokens for testing
    * @param amount the amount of tokens to be requested
    * @return valid Boolean indication of tokens are requested
    */
    function requestTokens(uint256 amount) public validAddress(msg.sender) returns (bool) {
        /* solium-disable-next-line security/no-block-members */
        if (block.timestamp < tokenRequest[msg.sender] + minPeriod) {
            emit FrequentTokenRequest(msg.sender, minPeriod);
            return false;
        }
        // amount should not exceed maxAmount
        if (amount > maxAmount) {
            require(mToken.transfer(msg.sender, maxAmount), 'Token transfer failed.');
            emit LimitTokenRequest(msg.sender, amount, maxAmount);
        } else {
            require(mToken.transfer(msg.sender, amount), 'Token transfer failed.');
        }
        /* solium-disable-next-line security/no-block-members */
        tokenRequest[msg.sender] = block.timestamp;
        return true;
    }

    /**
    * @dev Owner can limit the amount and time for token request in Testing
    * @param _amount the max amount of tokens that can be requested
    * @param _period the min amount of time before next request
    */
    function limitTokenRequest(uint _amount, uint _period) public onlyOwner() {
        // set min period of time before next request (in seconds)
        minPeriod = _period;
        // set max amount for each request
        maxAmount = _amount;
    }

    /**
    * @dev OceanMarket checks the voting result of OceanRegistry
    * @param listing the identifier of voting
    * @return valid Boolean indication of listing is whitelisted
    */
    function checkListingStatus(bytes32 listing) public view returns (bool){
        return tcr.isWhitelisted(listing);
    }

    /**
    * @dev OceanRegistry changes the asset status according to the voting result
    * @param assetId the integer identifier of asset in the voting
    * @return valid Boolean indication of asset is whitelisted
    */
    function deactivateAsset(bytes32 assetId) public returns (bool){
        // disable asset if it is not whitelisted in the registry
        if (!tcr.isWhitelisted(assetId)) {
            mAssets[assetId].active = false;
        }
        return true;
    }

    /**
    * @dev OceanMarket add the deployed address of OceanAuth contract
    * @return valid Boolean indication of contract address is updated
    */
    function addAuthAddress() public validAddress(msg.sender) returns (bool) {
        // authAddress can only be set at deployment of Auth contract - only once
        require(authAddress == address(0), 'authAddress is not 0x0');
        authAddress = msg.sender;
        return true;
    }

    /**
    * @dev OceanMarket add the deployed address of OceanDispute contract
    * @return valid Boolean indication of contract address is updated
    */
    function addDisputeAddress() public validAddress(msg.sender) returns (bool) {
        // authAddress can only be set at deployment of Auth contract - only once
        require(disputeAddress == address(0), 'disputeAddress is not 0x0');
        disputeAddress = msg.sender;
        return true;
    }

    /**
    * @dev OceanMarket generates bytes32 identifier for asset
    * @param contents the meta data information of asset as string
    * @return bytes32 as the identifier of asset
    */
    function generateId(string contents) public pure returns (bytes32) {
        // Generate the hash of input string
        return bytes32(keccak256(abi.encodePacked(contents)));
    }

    /**
    * @dev OceanMarket generates bytes32 identifier for asset
    * @param contents the meta data information of asset as bytes
    * @return bytes32 as the identifier of asset
    */
    function generateId(bytes contents) public pure returns (bytes32) {
        // Generate the hash of input bytes
        return bytes32(keccak256(abi.encodePacked(contents)));
    }

    /**
    * @dev OceanMarket check status of asset
    * @param assetId the integer identifier of asset
    * @return valid Boolean indication of asset is active or not
    */
    function checkAsset(bytes32 assetId) public view returns (bool) {
        return mAssets[assetId].active;
    }

    /**
    * @dev OceanMarket check price of asset
    * @param assetId the integer identifier of asset
    * @return integer as price of asset
    */
    function getAssetPrice(bytes32 assetId) public view returns (uint256) {
        return mAssets[assetId].price;
    }

}

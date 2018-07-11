pragma solidity ^0.4.21;

import './token/OceanToken.sol';
import './tcr/Registry.sol';
import './bondingCurve/BancorFormula.sol';

import './zeppelin/Ownable.sol';
import './zeppelin/SafeMath.sol';

contract Market is BancorFormula, Ownable {

    using SafeMath for uint256;
    using SafeMath for uint;

    // data Asset
    struct Asset{
        address owner;                          // owner of the Asset
        uint256 ndrops;                         // total supply of Drops
        uint256 nOcean;                         // poolBalance of dataset
        uint256 price;                          // price of asset
        bool active;                            // status of asset
        mapping (address => uint256) drops;     // mapping provider (address) to their stakes on dataset Sij
        mapping (address => uint256) delivery;  // mapping provider (address) to their #delivery of dataset Dj
    }
    mapping (uint256 => Asset) public mAssets;           // mapping assetId to Asset struct

    // data Provider
    struct Provider{
        address provider;
        uint256 numOCN;                        // Ocean token balance
        uint256 allowanceOCN;                  // available Ocean tokens for transfer excuding locked tokens for staking
        uint256 uploadBits;                    // total number of bits that served across all data assets with stakes
        uint256 downloadBits;                  // total number of bits that download across all data assets with stakes
    }
    mapping (address => Provider) public mProviders;    // mapping providerId to Provider struct

    // marketplace global variables
    OceanToken  public  mToken;
    uint256     public  mAllowance;             // total available Ocean tokens for transfer (exclude locked tokens)
    uint256     public  rewardPool;             // T_difficulty: total OCN emitted during the interval

    // bonding Curve
    uint256 public totalSupply = 10;          // initial total supply
    uint256 public poolBalance = 1;           // poolBalance for specific dataset
    uint32  public reserveRatio = 500000;      // max 1000000, reserveRatio = 20%
    uint256 public tokensToMint = 0;


    ////////////////// plankton mvp 2.0 ///////////////////
    //order
    struct Order {
        uint256 assetId;
        address provider;
        address consumer;
        bool    delivered;
        bool    paid;
        string  url;
        string  token;
    }
    mapping (uint256 => Order ) public mOrders;
    string empty;
    //////////////////////////////////////////////////////

    // Events
    event AssetRegistered(uint256 indexed _assetId, address indexed _owner);
    event AssetPublished(uint256 indexed _assetId, uint256 indexed _orderId, address indexed _owner);
    event AssetPurchased(uint256 indexed _assetId, uint256 indexed _orderId, address indexed _owner);

    event TokenWithdraw(address indexed _requester, uint256 amount);
    event TokenBuyDrops(address indexed _requester, uint256 indexed _assetId, uint256 _ocn, uint256 _drops);
    event TokenSellDrops(address indexed _requester, uint256 indexed _assetId, uint256 _ocn, uint256 _drops);


    // TCR
    Registry  public  tcr;

    function checkListingStatus(bytes32 listing, uint256 assetId) public view returns(bool){
        return tcr.isWhitelisted(listing);
    }

    function changeListingStatus(bytes32 listing, uint256 assetId) public returns(bool){
        if ( !tcr.isWhitelisted(listing) ){
            mAssets[assetId].active = false;
        }
        return true;
    }

    ///////////////////////////////////////////////////////////////////
    //  Query function
    ///////////////////////////////////////////////////////////////////
    // query encrypted url by Consumer
    function getEncUrl(uint256 orderId) public view returns (string) {
        require(msg.sender == mOrders[orderId].consumer);
        return mOrders[orderId].url;
    }

    // query encrypted token by Consumer
    function getEncToken(uint256 orderId) public view returns (string) {
        require(msg.sender == mOrders[orderId].consumer);
        return mOrders[orderId].token;
    }


    // Return the number of drops associated to the message.sender to an Asset
    function dropsBalance(uint256 assetId) public view returns (uint256){
        require(msg.sender != 0x0);
        return mAssets[assetId].drops[msg.sender];
    }

    // Return true or false if an Asset is active given the assetId
    function checkAsset(uint256 assetId) public view returns (bool) {
        return mAssets[assetId].active;
    }

    // Retrieve the msg.sender Provider token balance
    function tokenBalance() public view returns (uint256) {
        require(mProviders[msg.sender].provider != 0x0);
        return mProviders[msg.sender].numOCN;
    }
    ///////////////////////////////////////////////////////////////////
    //  Constructor function
    ///////////////////////////////////////////////////////////////////
    // 1. constructor
    function Market(address _tokenAddress, address _tcrAddress) public {
        require(_tokenAddress != address(0));
        // instantiate deployed Ocean token contract
        mToken = OceanToken(_tokenAddress);
        // instance of TCR
        tcr = Registry(_tcrAddress);
        // set the token receiver to be marketplace
        mToken.setReceiver(address(this));
        // setReceiver funciton will transfer initial funds to Market contract
        mAllowance = mToken.balanceOf(address(this));
    }

    ///////////////////////////////////////////////////////////////////
    // Actor and Asset routine procedures
    ///////////////////////////////////////////////////////////////////

    // 1. register provider and assets （upload by changing uploadBits）
    function register(uint256 assetId, uint256 price) public returns (bool success) {
        require(msg.sender != 0x0);
        // register provider
        mProviders[msg.sender] = Provider(msg.sender, 0, 0, 0, 0);

        // ndrops =10, nToken = 1 => phatom tokesn to avoid failure of Bancor formula
        mAssets[assetId] = Asset(msg.sender, 10, 1, price, false);  // Creates new struct and saves in storage. We leave out the mapping type.
        mAssets[assetId].active = true;

        emit AssetRegistered(assetId, msg.sender);
        return true;
    }


    // publish consumption information about an Asset
    function publish(uint256 assetId, uint256 orderId, string _url, string _token) public returns (bool success) {
        require(mAssets[assetId].owner != 0x0);
        // only owner of data asset can publish the accessing token for consumers
        require(msg.sender == mAssets[assetId].owner);
        // order must be paid first
        require(mOrders[orderId].paid == true);

        mOrders[orderId].url = _url;
        mOrders[orderId].token = _token;
        emit AssetPublished(assetId, orderId, msg.sender);
        return true;
    }

    // purchase an asset and get the consumption information - called by consumer
    function purchase(uint256 assetId, uint256 orderId) public returns (bool) {
        // data asset exists
        require(mAssets[assetId].owner != 0x0);

        mOrders[orderId] = Order(assetId, 0x0, msg.sender, false, false, empty, empty);
        // transfer fund
        require(mOrders[orderId].paid == false);
        mOrders[orderId].paid = true;
        require(mToken.transferFrom(msg.sender, address(this), mAssets[assetId].price));

        emit AssetPurchased(assetId, orderId, msg.sender);

        return true;
    }

    // provider set himself as the provider
    function setOrderProvider(uint256 orderId) public returns (bool) {
        require(msg.sender != 0x0);
        // order must be paid first
        require(mOrders[orderId].paid == true);
        // set himself as the provider
        mOrders[orderId].provider = msg.sender;
        return true;
    }

    // consumer confirms the confirmDelivery
    function confirmDelivery(uint256 orderId) public returns (bool) {
        require(msg.sender == mOrders[orderId].consumer);
        mOrders[orderId].delivered = true;
        return true;
    }

    // provider request payment for serving the download request
    function requestPayment(uint256 orderId) public returns (bool) {
        // provider must served the download request
        require(mOrders[orderId].delivered == true);
        // the requester of payment must be the provider of this order
        require(mOrders[orderId].provider == msg.sender);
        // initiate the transfer
        var assetId = mOrders[orderId].assetId;
        require(mToken.transfer(msg.sender, mAssets[assetId].price));
        return true;
    }

        // 2. request initial fund transfer
    function requestTokens(uint256 amount) public returns (uint256) {
        require(msg.sender != 0x0);
        // find amount of tokens need or can be transferred
        uint256 nToken = 0;
        if (mAllowance >= amount){
            nToken = amount;
        } else {
            nToken = mAllowance;
        }
        // withdraw tokens from Marketplace -> remember to decrease allowance first!!
        mAllowance = mAllowance.sub(nToken);
        // the OCN tokens is held in user wallet rather than market escrow accounts -> do not change provider balances
        require(mToken.transfer(msg.sender, nToken));
        return nToken;
    }


    // 5. withdraw
    function withdraw() public returns (bool) {
        //require(mProviders[msg.sender].allowanceOCN >= mProviders[msg.sender].numOCN);
        //require(mAllowance >= mProviders[msg.sender].numOCN);
        uint256 amount = mProviders[msg.sender].numOCN;
        mProviders[msg.sender].numOCN = 0;
        mAllowance.sub(amount);
        mProviders[msg.sender].allowanceOCN.sub(amount);
        require(mToken.transfer(msg.sender, amount));

        emit TokenWithdraw(msg.sender, amount);
        return true;
    }




    ///////////////////////////////////////////////////////////////////
    // Block Reward Module
    ///////////////////////////////////////////////////////////////////

    // marketplace request the emitted Ocean Tokens which are transferred to market
    function mintToken() public returns (uint256 balance) {
        uint256 previous = mToken.balanceOf(address(this));
        require(mToken.emitTokens());
        uint256 current = mToken.balanceOf(address(this));
        // credit emitted tokens to block reward pool
        rewardPool = rewardPool.add(current.sub(previous));

        // raise the limit of token allowance for marketplace
        mAllowance = mAllowance.add(current.sub(previous));
        // return the current token balance
        return current;
    }

    ///////////////////////////////////////////////////////////////////
    // Bonding Curve Module
    ///////////////////////////////////////////////////////////////////

    // 1. bondingCurve function - buy Drops - call by any actors
    function buyDrops(uint256 _assetId, uint256 _ocn) public returns (uint256 _drops) {
        tokensToMint = calculatePurchaseReturn(mAssets[_assetId].ndrops, mAssets[_assetId].nOcean, reserveRatio, _ocn);
        mAssets[_assetId].ndrops = mAssets[_assetId].ndrops.add(tokensToMint);
        mAssets[_assetId].nOcean = mAssets[_assetId].nOcean.add(_ocn);

        // First transfer _ocn tokens into Marketplace escrow account to purchase Drops
        mProviders[msg.sender].numOCN = mProviders[msg.sender].numOCN.add(_ocn);
        mProviders[msg.sender].allowanceOCN = mProviders[msg.sender].allowanceOCN.add(_ocn);
        mAllowance = mAllowance.add(_ocn);
        require(mToken.transferFrom(msg.sender, address(this), _ocn));

        // 4. update balances

        // increment total ndrops
        totalSupply = totalSupply.add(tokensToMint);
        poolBalance = poolBalance.add(_ocn);

        //mAssets[_assetId].ndrops += tokensToMint;
        // lock ocean Tokens
        mProviders[msg.sender].numOCN = mProviders[msg.sender].numOCN.sub(_ocn);
        mProviders[msg.sender].allowanceOCN = mProviders[msg.sender].allowanceOCN.sub(_ocn);
        mAllowance = mAllowance.sub(_ocn);
        mAssets[_assetId].drops[msg.sender] = mAssets[_assetId].drops[msg.sender].add(tokensToMint);

        emit TokenBuyDrops(msg.sender, _assetId, _ocn, tokensToMint);

        return tokensToMint;
    }

    function sellDrops(uint256 _assetId, uint256 _drops) public returns (uint256 _ocn) {
        require(mProviders[msg.sender].provider != 0x0);

        uint256 ocnAmount = calculateSaleReturn(mAssets[_assetId].ndrops, mAssets[_assetId].nOcean, reserveRatio, _drops);
        mAssets[_assetId].ndrops = mAssets[_assetId].ndrops.sub(_drops);
        mAssets[_assetId].nOcean = mAssets[_assetId].nOcean.sub(ocnAmount);

        // 4. update balances
        totalSupply = totalSupply.sub(_drops);
        poolBalance = poolBalance.sub(ocnAmount);
        // unlock ocean Tokens
        mProviders[msg.sender].numOCN = mProviders[msg.sender].numOCN.add(ocnAmount);
        mProviders[msg.sender].allowanceOCN = mProviders[msg.sender].allowanceOCN.add(ocnAmount);
        mAllowance = mAllowance.add(ocnAmount);
        // decrement drops balance of actors
        mAssets[_assetId].drops[msg.sender] = mAssets[_assetId].drops[msg.sender].sub(_drops);

        emit TokenSellDrops(msg.sender, _assetId, ocnAmount, _drops);

        return ocnAmount;
    }


    ///////////////////////////////////////////////////////////////////
    // XOR random number generator
    ///////////////////////////////////////////////////////////////////

    function rng(uint256 limit) public view returns (uint256) {
        return uint256(uint256(keccak256(block.timestamp, block.difficulty))%limit); // solium-disable-line security/no-block-members
    }


    ///////////////////////////////////////////////////////////////////
    // Utility Functions
    ///////////////////////////////////////////////////////////////////
    /*
     *  Constants
     */
    // This is equal to 1 in our calculations
    uint public constant ONE =  0x10000000000000000;
    uint public constant LN2 = 0xb17217f7d1cf79ac;
    uint public constant LOG2_E = 0x171547652b82fe177;

    // 1. square root function
    function sqrt(uint x) internal pure returns (uint y) {
        if (x == 0) return 0;
        else if (x <= 3) return 1;
        uint z = (x + 1).div(2);
        y = x;
        while (z < y){
            y = z;
            // z = (x/z + z) / 2
            z = (x.div(z).add(z)).div(2);
        }
    }


    /// @dev Returns maximum of an array
    /// @param i1 Numbers to look through
    /// @param i2 Numbers to look through
    /// @return Maximum number
    function findMax(uint256 i1, uint256 i2) internal pure returns (uint) {
        if (i1 > i2) {
            return i1;
        } else {
            return i2;
        }
    }

    // calculate hash of input parameter - string
    function generateStr2Id(string contents) public pure returns (bytes32) {
        // Generate the hash of input bytes
        return bytes32(keccak256(contents));
    }

    // calculate hash of input parameter - bytes
    function generateBytes2Id(bytes contents) public pure returns (bytes32) {
        // Generate the hash of input bytes
        return bytes32(keccak256(contents));
    }

    // for debugging use only
    uint256 public counter = 0;
    function increment() public returns (bool) {
        counter.add(1);
        return true;
    }


}

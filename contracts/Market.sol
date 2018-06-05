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
          uint256 bitSize;                        // size of asset in bit
          bytes32 url;                            // url of the asset
          bytes32 token;                          // token to get access to the asset
          mapping (address => uint256) drops;     // mapping provider (address) to their stakes on dataset Sij
          mapping (address => uint256) delivery;  // mapping provider (address) to their #delivery of dataset Dj
    }
    mapping (uint256 => Asset) public mAssets;           // mapping assetId to Asset struct
    uint256[50] public  listAssets;
    uint256     private  sizeListAssets= 0;

    // data Provider
    struct Provider{
          address provider;
          uint256 numOCN;                        // Ocean token balance
          uint256 allowanceOCN;                  // available Ocean tokens for transfer excuding locked tokens for staking
          uint256 uploadBits;                    // total number of bits that served across all data assets with stakes
          uint256 downloadBits;                  // total number of bits that download across all data assets with stakes
    }
    mapping (address => Provider) public mProviders;    // mapping providerId to Provider struct
    address[50] public  listProviders;
    uint256     public sizeProviders= 0;
    uint256     public winProvider = 0;

    // marketplace global variables
    OceanToken  public  mToken;
    uint256     public  mAllowance;             // total available Ocean tokens for transfer (exclude locked tokens)
    uint256     public  rewardPool;             // T_difficulty: total OCN emitted during the interval

    // bonding Curve
    uint256 public totalSupply = 10;          // initial total supply
    uint256 public poolBalance = 1;           // poolBalance for specific dataset
    uint32  public reserveRatio = 500000;      // max 1000000, reserveRatio = 20%
    uint256 public tokensToMint = 0;

    // TCR
    Registry  public  tcr;

    function checkListingStatus(bytes32 listing) public view returns(bool){
      return tcr.isWhitelisted(listing);
    }

    ///////////////////////////////////////////////////////////////////
    //  Query function
    ///////////////////////////////////////////////////////////////////
    function dropsBalance(uint256 assetId) public view returns (uint256){
        require(msg.sender != 0x0);
        return mAssets[assetId].drops[msg.sender];
    }

    function rnd() public view returns (uint256) {
      return winProvider;
    }

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
    function register(uint256 assetId) public returns (bool success) {
      require(msg.sender != 0x0);
      // register provider
      mProviders[msg.sender] = Provider(msg.sender, 0, 0, 0, 0);

      // register assets
      uint256 fileSize = 1024;
      mAssets[assetId] = Asset(msg.sender, 0, fileSize, 0, 0);  // Creates new struct and saves in storage. We leave out the mapping type.

      if (sizeListAssets < 50)  {
          listAssets[sizeListAssets] = assetId;
          sizeListAssets += 1;
      }

      // simulate uploading dataSet
      mProviders[msg.sender].uploadBits = fileSize;
      return true;
    }


    // publish consumption information about an Asset
    function publish(uint256 assetId, bytes32 _url, bytes32 _token) external returns (bool success) {
         require(mAssets[assetId].owner != 0x0);
         require(msg.sender == mAssets[assetId].owner);

        mAssets[assetId].url= _url;
        mAssets[assetId].token= _token;
    }

    // purchase an asset and get the consumption information - called by consumer
    function purchase(uint256 assetId) external returns (bytes32 url, bytes32 token) {
        require(mAssets[assetId].owner != 0x0);

        // increment counter
        if (sizeProviders < 50)  {
          listProviders[sizeProviders] = mAssets[assetId].owner;
          sizeProviders += 1;
          mAssets[assetId].delivery[mAssets[assetId].owner] += 1;
        }

        // request token rewards for provider
        winProvider = rng(sizeProviders);
        if(rewardPool != 0 && winProvider >= 0 && winProvider < sizeProviders ){
          address winner = listProviders[winProvider];
          mProviders[winner].numOCN += rewardPool;
          rewardPool = 0 ;
        }

        return (mAssets[assetId].url, mAssets[assetId].token);
    }

    function listAssets() external view returns (uint256[50]) {
        return listAssets;
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
      mAllowance -= nToken;
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
      mAllowance -= amount;
      mProviders[msg.sender].allowanceOCN -= amount;
      require(mToken.transfer(msg.sender, amount));
      return true;
    }




    ///////////////////////////////////////////////////////////////////
    // Block Reward Module
    ///////////////////////////////////////////////////////////////////

    // marketplace request the emitted Ocean Tokens which are transferred to market
    function mintToken() public returns (uint256 balance) {
      uint256 previous = mToken.balanceOf(address(this));
      require(mToken.emitTokens());
      uint256 current  = mToken.balanceOf(address(this));
      // credit emitted tokens to block reward pool
      rewardPool += current - previous;

      // raise the limit of token allowance for marketplace
      mAllowance += current - previous;
      // return the current token balance
      return current;
    }

    ///////////////////////////////////////////////////////////////////
    // Bonding Curve Module
    ///////////////////////////////////////////////////////////////////

    // 1. bondingCurve function - buy Drops - call by any actors
    function buyDrops(uint256 _assetId, uint256 _ocn) public returns (uint256 _drops) {
      // First transfer _ocn tokens into Marketplace escrow account to purchase Drops
      mProviders[msg.sender].numOCN += _ocn;
      mProviders[msg.sender].allowanceOCN += _ocn;
      mAllowance += _ocn;
      require(mToken.transferFrom(msg.sender, address(this), _ocn));


      //uint256 tokensToMint = 0; mAssets[_assetId].ndrops
      tokensToMint = calculatePurchaseReturn(totalSupply, poolBalance, reserveRatio, _ocn);
      mAssets[_assetId].ndrops = mAssets[_assetId].ndrops.add(tokensToMint);

      // 4. update balances

      // increment total ndrops
      totalSupply  += tokensToMint;
      poolBalance = poolBalance.add(_ocn);

      //mAssets[_assetId].ndrops += tokensToMint;
      // lock ocean Tokens
      mProviders[msg.sender].numOCN -= _ocn;
      mProviders[msg.sender].allowanceOCN -= _ocn;
      mAllowance -= _ocn;
      mAssets[_assetId].drops[msg.sender] += tokensToMint;

      return tokensToMint;
    }

    function sellDrops(uint256 _assetId, uint256 _drops) public returns (uint256 _ocn) {
      require(mProviders[msg.sender].provider != 0x0);

      uint256 ocnAmount = calculateSaleReturn(totalSupply, poolBalance, reserveRatio, _drops);

      // 4. update balances
      totalSupply = totalSupply.sub(_drops);
      poolBalance = poolBalance.sub(ocnAmount);
      // decrement total ndrops
      mAssets[_assetId].ndrops = mAssets[_assetId].ndrops.sub(_drops);
      // unlock ocean Tokens
      mProviders[msg.sender].numOCN += ocnAmount;
      mProviders[msg.sender].allowanceOCN += ocnAmount;
      mAllowance += ocnAmount;
      // decrement drops balance of actors
      mAssets[_assetId].drops[msg.sender] -= _drops;
      return ocnAmount;
    }


    ///////////////////////////////////////////////////////////////////
    // XOR random number generator
    ///////////////////////////////////////////////////////////////////

    function rng(uint256 limit) public view returns (uint256) {
      return uint256(uint256(keccak256(block.timestamp, block.difficulty))%limit);
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
        uint z = (x + 1) / 2;
        y = x;
        while (z < y){
            y = z;
            z = (x / z + z) / 2;
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


}

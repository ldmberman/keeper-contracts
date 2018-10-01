// solium-disable security/no-block-members, emit

pragma solidity 0.4.25;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

import '../token/OceanToken.sol';


/**
 * Exchange between Ethers and Ocean tokensIn
 * Developed based on Uniswap project. https://github.com/Uniswap/
 */

contract OceanExchange {
    using SafeMath for uint256;

    /// EVENTS
    event EthToTokenPurchase(address indexed buyer, uint256 indexed ethIn, uint256 indexed tokensOut);
    event TokenToEthPurchase(address indexed buyer, uint256 indexed tokensIn, uint256 indexed ethOut);
    event AddLiquidity(address indexed liquidityProvider, uint256 indexed sharesPurchased);
    event RemoveLiquidity(address indexed liquidityProvider, uint256 indexed sharesBurned);

    /// CONSTANTS
    uint256 public constant FEE_RATE = 500;        //fee = 1/feeRate = 0.2%

    /// STORAGE
    uint256 public ethPool;
    uint256 public tokenPool;
    uint256 public invariant;
    uint256 public totalShares;
    mapping(address => uint256) shares;
    OceanToken  public  token;

    /// MODIFIERS
    modifier exchangeInitialized() {
        require(invariant > 0 && totalShares > 0);
        _;
    }

    /// CONSTRUCTOR
    constructor(address _tokenAddress) public {
        require(_tokenAddress != address(0x0), 'Token address is 0x0.');
        // instantiate Ocean token contract
        token = OceanToken(_tokenAddress);
    }

    // display current exchange snapshot
    function exchangeStatus() public view returns (uint256, uint256, uint256, uint256) {
        return (ethPool, tokenPool, invariant, totalShares);
    }

    /// pay ether for tokens
    function() public payable {
        require(msg.value != 0);
        ethToToken(msg.sender, msg.sender, msg.value, 1);
    }

    /// Initialize the exchange
    function initializeExchange(uint256 _tokenAmount) external payable {
        require(invariant == 0 && totalShares == 0);
        // Prevents share cost from being too high or too low - potentially needs work
        require(msg.value >= 10000 && _tokenAmount >= 10000 && msg.value <= 5 * 10 ** 18);
        ethPool = msg.value;
        tokenPool = _tokenAmount;
        invariant = ethPool.mul(tokenPool);
        // share for the first user
        shares[msg.sender] = 1000;
        totalShares = 1000;
        require(token.transferFrom(msg.sender, address(this), _tokenAmount));
    }

    //////////////////////////
    // ETH to Token Exchange
    //////////////////////////

    /// INTERNAL FUNCTIONS
    function ethToToken(
        address buyer,
        address recipient,
        uint256 ethIn,
        uint256 minTokensOut
    )
    internal
    exchangeInitialized
    {
        // calculate value of tx fee
        uint256 fee = ethIn.div(FEE_RATE);
        // add eth payment into the ethPool
        uint256 newEthPool = ethPool.add(ethIn);
        // substract the tx fee
        uint256 tempEthPool = newEthPool.sub(fee);
        // keep the invariant => find new tokenPool value
        uint256 newTokenPool = invariant.div(tempEthPool);
        // calculate the payout of tokens
        uint256 tokensOut = tokenPool.sub(newTokenPool);
        // payout value must be valid
        require(tokensOut >= minTokensOut && tokensOut <= tokenPool);
        // update exchange pools
        ethPool = newEthPool;
        tokenPool = newTokenPool;
        invariant = newEthPool.mul(newTokenPool);
        // event
        emit EthToTokenPurchase(buyer, ethIn, tokensOut);
        // transfer tokens
        require(token.transfer(recipient, tokensOut));
    }


    // Buyer swaps ETH for Tokens
    function ethToTokenSwap(
        uint256 _minTokens,
        uint256 _timeout
    )
    external
    payable
    {
        require(msg.value > 0 && _minTokens > 0 && now < _timeout);
        ethToToken(msg.sender, msg.sender, msg.value, _minTokens);
    }

    // Payer pays in ETH, recipient receives Tokens
    function ethToTokenPayment(
        uint256 _minTokens,
        uint256 _timeout,
        address _recipient
    )
    external
    payable
    {
        require(msg.value > 0 && _minTokens > 0 && now < _timeout);
        require(_recipient != address(0) && _recipient != address(this));
        ethToToken(msg.sender, _recipient, msg.value, _minTokens);
    }

    //////////////////////////
    // Token to ETH Exchange
    //////////////////////////

    function tokenToEth(
        address buyer,
        address recipient,
        uint256 tokensIn,
        uint256 minEthOut
    )
    internal
    exchangeInitialized
    {
        // calculate tx fee
        uint256 fee = tokensIn.div(FEE_RATE);
        // add deposit tokens into tokenPool
        uint256 newTokenPool = tokenPool.add(tokensIn);
        // substract tx fee from the tokenPool
        uint256 tempTokenPool = newTokenPool.sub(fee);
        // calculate new ethPool using current invariant
        uint256 newEthPool = invariant.div(tempTokenPool);
        // compute the payout ether that is difference
        uint256 ethOut = ethPool.sub(newEthPool);
        // payout value of ether must be valid
        require(ethOut >= minEthOut && ethOut <= ethPool);
        // update values of exchange
        tokenPool = newTokenPool;
        ethPool = newEthPool;
        // update invariant
        invariant = newEthPool.mul(newTokenPool);
        // event
        emit TokenToEthPurchase(buyer, tokensIn, ethOut);
        // transfer tokens into exchange - revert previous changes if failed
        require(token.transferFrom(buyer, address(this), tokensIn));
        // transfer ether into recipient account
        recipient.transfer(ethOut);
    }

    // Buyer swaps Tokens for ETH
    function tokenToEthSwap(
        uint256 _tokenAmount,
        uint256 _minEth,
        uint256 _timeout
    )
    external
    {
        require(_tokenAmount > 0 && _minEth > 0 && now < _timeout);
        tokenToEth(msg.sender, msg.sender, _tokenAmount, _minEth);
    }

    // Payer pays in Tokens, recipient receives ETH
    function tokenToEthPayment(
        uint256 _tokenAmount,
        uint256 _minEth,
        uint256 _timeout,
        address _recipient
    )
    external
    {
        require(_tokenAmount > 0 && _minEth > 0 && now < _timeout);
        require(_recipient != address(0) && _recipient != address(this));
        tokenToEth(msg.sender, _recipient, _tokenAmount, _minEth);
    }


    //////////////////////////
    // Add or remove liquidity
    //////////////////////////

    // Invest liquidity and receive market shares
    function addLiquidity(uint256 min_amount, uint256 _timeout) external payable exchangeInitialized {
        // check validity of inputs
        require(msg.value > 0 && min_amount > 0 && now < _timeout);
        // calculate current price of share denominated in ether
        uint256 ethPerShare = ethPool.div(totalShares);
        // ether payment must be able to buy > 1 share
        require(msg.value >= ethPerShare);
        // calculate the amount of shares that the ether payment can purchase
        uint256 sharesPurchased = msg.value.div(ethPerShare);
        // num of share purchased must be valid
        require(sharesPurchased > 0);
        // calculate current price of share denominated in ERC20 token
        uint256 tokensPerShare = tokenPool.div(totalShares);
        // the required token amount for this share purchase (add both ether and token for current price)
        uint256 tokensRequired = sharesPurchased.mul(tokensPerShare);
        // add purchased shares to buyer account
        shares[msg.sender] = shares[msg.sender].add(sharesPurchased);
        // update exchange share information -> purchased shares are new issued shares
        totalShares = totalShares.add(sharesPurchased);
        // update balance of etherPool and tokenPool & invariant
        ethPool = ethPool.add(msg.value);
        tokenPool = tokenPool.add(tokensRequired);
        invariant = ethPool.mul(tokenPool);
        // event
        emit AddLiquidity(msg.sender, sharesPurchased);
        // transfer tokens - revert all previous changes if failed
        require(token.transferFrom(msg.sender, address(this), tokensRequired));
    }

    // sell market shares and receive liquidity
    function removeLiquidity(uint256 _sharesBurned, uint256 _minEth, uint256 _minTokens, uint256 _timeout) external exchangeInitialized {
        // valid inputs
        require(_sharesBurned > 0 && now < _timeout);
        // substract shared to be burned from seller account
        shares[msg.sender] = shares[msg.sender].sub(_sharesBurned);
        // calculate current price of share denominated in ether
        uint256 ethPerShare = ethPool.div(totalShares);
        // calculate current price of share denominated in token
        uint256 tokensPerShare = tokenPool.div(totalShares);
        // calculate the ether value of shares to be burned
        uint256 ethDivested = ethPerShare.mul(_sharesBurned);
        // calculate the token value of shares to be burned
        uint256 tokensDivested = tokensPerShare.mul(_sharesBurned);
        // ether & token amount for shares to be burned should be valid
        require(ethDivested >= _minEth && tokensDivested >= _minTokens);
        // update exchange information
        totalShares = totalShares.sub(_sharesBurned);
        ethPool = ethPool.sub(ethDivested);
        tokenPool = tokenPool.sub(tokensDivested);
        // if there no share remaining -> reset the exchange
        if (totalShares == 0) {
            invariant = 0;
        } else {
            invariant = ethPool.mul(tokenPool);
        }
        // event
        emit RemoveLiquidity(msg.sender, _sharesBurned);
        // transfer tokens to seller
        require(token.transfer(msg.sender, tokensDivested));
        // transfer ether to seller
        msg.sender.transfer(ethDivested);
    }

    // Utility Function : View share balance of an address
    function getShares(address _provider) external view returns (uint256 _shares) {
        return shares[_provider];
    }
}

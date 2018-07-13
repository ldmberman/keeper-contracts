pragma solidity ^0.4.21;

import '../Market.sol';

import '../zeppelin/StandardToken.sol';
import '../zeppelin/Ownable.sol';

contract ACL {

    using SafeMath for uint256;
    using SafeMath for uint;

    // marketplace global variables
    Market  public  market;

    struct Order {
        bytes32 resourceId;       // resource identifier
        address provider;         // provider address
        address consumer;         // consumer address
        bool    delivered;        // resource delivered - true
        bool    paid;             // order is paid - true
        bool    confirmed;        // order is confirmed by provider - true
        string tmpPubKey;        // consumer generated temp public key
        string  token;            // provider generated encrypted access token
    }
    mapping (bytes32 => Order ) public mOrders;   // mapping orderId to associated Order struct
    string empty;

    // Events
    event OrderCreated(bytes32 indexed _resourceId, bytes32 indexed _orderId, address indexed _consumer);
    event OrderConfirmed(bytes32 indexed _orderId, address indexed _provider);
    event OrderPaid(bytes32 indexed _orderId, address indexed _provider);
    event OrderDelivered(bytes32 indexed _orderId, address indexed _consumer);

    event TempKeyCreated(bytes32 indexed _orderId, string _tempPublicKey, address indexed _consumer);
    event TokenCreated(bytes32 indexed _orderId, address indexed _provider);

    ///////////////////////////////////////////////////////////////////
    //  Constructor function
    ///////////////////////////////////////////////////////////////////
    // 1. constructor
    function ACL(address _marketAddress) public {
        require(_marketAddress != address(0));
        // instance of Market
        market = Market(_marketAddress);
    }


    ///////////////////////////////////////////////////////////////////
    // Query Functions
    ///////////////////////////////////////////////////////////////////
    // provider query the temp public key of order
    function queryTempKey(bytes32 orderId) public view returns (string) {
        return mOrders[orderId].tmpPubKey;
    }

    // consumer query the encrypted access token of order
    function queryToken(bytes32 orderId) public view returns (string) {
        return mOrders[orderId].token;
    }


    ///////////////////////////////////////////////////////////////////
    // Transaction Functions
    ///////////////////////////////////////////////////////////////////
    // 1. consumer create an order
    function createOrder(bytes32 resourceId, bytes32 orderId, address provider) public returns (bool success) {
        // consumer address cannot be empty
        require(msg.sender != 0x0);
        // order Id shall be unique
        require(mOrders[orderId].consumer == 0x0);
        // create an order using input orderId
        mOrders[orderId] = Order(resourceId, provider, msg.sender, false, false, false, empty, empty);
        // emit event
        emit OrderCreated(resourceId, orderId, msg.sender);
        return true;
    }

    // 2. proivder needs to confirm the order
    function providerConfirm(bytes32 orderId) public returns (bool success) {
        // must be provider of this order to confirm the order
        require(msg.sender == mOrders[orderId].provider);
        require(mOrders[orderId].confirmed == false);
        // confirm the order
        mOrders[orderId].confirmed = true;
        // emit an event
        emit OrderConfirmed(orderId, msg.sender);
        return true;
    }

    // 3. consumer pay the order and transfer funds to marketplace contract
    //require(mToken.transferFrom(msg.sender, address(this), mAssets[assetId].price));
    function payOrder(bytes32 orderId) public returns (bool success) {
        // consumer address cannot be empty
        require(msg.sender != 0x0);
        // must be consumer of the order to make payment
        require(msg.sender == mOrders[orderId].consumer);
        // order must be confirmed by provider First
        require(mOrders[orderId].confirmed = true);
        // call makePayment function in Market contract
        require(mOrders[orderId].paid == false);
        require(market.makePayment(msg.sender, mOrders[orderId].resourceId));
        // update order status
        mOrders[orderId].paid = true;
        // emit an event
        emit OrderPaid(orderId, msg.sender);
        return true;
    }

    // 4. consumer publish temp public key
    function addTempPubKey(bytes32 orderId, string tempPubKey) public returns (bool success) {
        // consumer address cannot be empty
        require(msg.sender != 0x0);
        // must be consumer of the order to make payment
        require(msg.sender == mOrders[orderId].consumer);
        // must be paid first
        require(mOrders[orderId].paid == true);
        // add temp public key
        mOrders[orderId].tmpPubKey = tempPubKey;
        // emit an event
        emit TempKeyCreated(orderId, tempPubKey, msg.sender);
        return true;
    }

    // 5. provider add encrypted token on-chain
    function addToken(bytes32 orderId, string token) public returns (bool success) {
        // consumer address cannot be empty
        require(msg.sender != 0x0);
        // must be consumer of the order to make payment
        require(msg.sender == mOrders[orderId].provider);
        // add encrypted token to Order
        mOrders[orderId].token = token;
        // emit an event
        emit TokenCreated(orderId, msg.sender);
        return true;
    }

    // 6. consumer confirms the delivery of resource
    function confirmDelivery(bytes32 orderId) public returns (bool) {
        // must be consumer to confirm the order
        require(msg.sender == mOrders[orderId].consumer);
        // order must be not marked as delivered at this time
        require(mOrders[orderId].delivered == false);
        // update order status to be delivered
        mOrders[orderId].delivered = true;
        // release fund to provider - interact with market contract
        require(market.requestPayment(mOrders[orderId].provider, mOrders[orderId].resourceId));
        // emit an event
        emit OrderDelivered(orderId, msg.sender);
        return true;
    }

    ///////////////////////////////////////////////////////////////////
    // Utility Functions
    ///////////////////////////////////////////////////////////////////
    function generateOrderId(string contents) public pure returns (bytes32) {
        return bytes32(keccak256(contents));
    }
}

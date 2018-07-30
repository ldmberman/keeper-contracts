pragma solidity ^0.4.21;

import '../zeppelin/StandardToken.sol';
import '../zeppelin/Ownable.sol';
//import 'zeppelin/math/SafeMath.sol';

contract OceanToken is StandardToken {

    using SafeMath for uint256;

    string public constant name = 'OceanToken';                         // Set the token name for display
    string public constant symbol = 'OCN';                              // Set the token symbol for display

    // SUPPLY
    uint8 public constant decimals = 2;                           // Set the number of decimals for display
    uint256 public constant TOTAL_SUPPLY = 80000;                 // OceanToken total supply
    uint256 public INITIAL_SUPPLY = TOTAL_SUPPLY.mul(55).div(100);    // 55% tokens is available initially
    uint256 public REWARD_SUPPLY = TOTAL_SUPPLY.sub(INITIAL_SUPPLY);  // 45% of totalSupply is used for block rewards
    uint256 public numReward = 0;                                     // number of reward tokens
    uint256 public initTime;                                          // initial timestamp of contract creation

    // EMIT TOKENS
    address public _receiver = 0x0;                                   // address to receive TOKENS
    uint256 public totalSupply;                                       // total supply of Ocean tokens including initial tokens plus block rewards

    /**
    * @dev OceanToken Constructor
    * Runs only on initial contract creation.
    */
    function OceanToken() public {
        totalSupply = INITIAL_SUPPLY;
        /* solium-disable-next-line security/no-block-members */
        initTime = block.timestamp;
    }

    /**
    * @dev setReceiver set the address to receive the emitted tokens
    * @param _to The address to send tokens
    * @return success setting is successful.
    */
    function setReceiver(address _to) public returns (bool success){
        require(_receiver == address(0), 'Receiver address is not 0x0.');
        _receiver = _to;
        // Creator address is assigned initial available tokens
        balances[_receiver] = INITIAL_SUPPLY;
        emit Transfer(0x0, _receiver, INITIAL_SUPPLY);
        return true;
    }

    /**
    * @dev Transfer token for a specified address when not paused
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), 'To address is 0x0.');
        return super.transfer(_to, _value);
    }

    /**
    * @dev Transfer tokens from one address to another when not paused
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), 'To address is 0x0.');
        return super.transferFrom(_from, _to, _value);
    }

    /**
    * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender when not paused.
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        return super.approve(_spender, _value);
    }

    /* solium-disable-next-line no-constant */
    function allowance(address _owner, address _spender) public constant returns (uint256) {
        return super.allowance(_owner, _spender);
    }

}

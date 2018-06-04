pragma solidity ^0.4.21;

import "../zeppelin/StandardToken.sol";
import "../zeppelin/Ownable.sol";
//import "zeppelin/math/SafeMath.sol";

contract OceanToken is StandardToken {

  using SafeMath for uint256;

  string public constant name = 'OceanToken';                                  // Set the token name for display
  string public constant symbol = 'OCN';                                       // Set the token symbol for display

  // SUPPLY
  uint8 public constant decimals = 2;  // 8;                                   // Set the number of decimals for display
  uint256 public constant TOTAL_SUPPLY = 80000; //1400000000 * 10**8;          // 1.4 billion OceanToken specified in Grains
  uint256 public INITIAL_SUPPLY = TOTAL_SUPPLY.mul(55).div(100);               // 55% tokens is available initially
  uint256 public REWARD_SUPPLY = TOTAL_SUPPLY.sub(INITIAL_SUPPLY);             // 45% of totalSupply is used for block rewards
  uint256 public numReward = 0;                                                // number of reward tokens
  uint256 public initTime;                                                     // initial timestamp of contract creation

  // EMIT TOKENS
  address public _receiver = 0x0;                                              // address to receive TOKENS
  uint256 public totalSupply;                                                  // total supply of Ocean tokens including initial tokens plus block rewards

  /**
   * @dev OceanToken Constructor
   * Runs only on initial contract creation.
   */
  function OceanToken() public {
    totalSupply = INITIAL_SUPPLY;
    initTime = now;
  }

  /**
   * @dev setReceiver set the address to receive the emitted tokens
   * @param _to The address to send tokens
   * @return success setting is successful.
   */
  function setReceiver(address _to) public returns(bool success){
    //require(_receiver == 0x0);
    _receiver = _to;
    balances[_receiver] = INITIAL_SUPPLY;                             // Creator address is assigned initial available tokens
    emit Transfer(0x0, _receiver, INITIAL_SUPPLY);
    return true;
  }

  /**
   * @dev emitTokens Ocean tokens according to schedule forumla
   * @return success the mining of Ocean tokens is successful.
   */
  function emitTokens() public returns (bool success) {
    // check if all tokens have been emitted
    if (totalSupply == TOTAL_SUPPLY){
      return true;
    }

    //uint256 tH = (now - initTime).div( 10 * 365 * 24 * 60 * 60 * 1 seconds );  // half-life is 10 years
    uint256 tH = (now - initTime).div( 30 * 1 seconds );            // half-life is 30 second: release 50% after 30 seconds
    uint256 base = 2 ** tH;
    uint256 nowReward = REWARD_SUPPLY.sub(REWARD_SUPPLY.div(base)); // nowReward is the amount of reward tokens at current timestamp

    uint256 newTokens = nowReward.sub(numReward);                   // newTokens is the amount of newly-emitted tokens
    numReward = nowReward;

    // update total supply
    totalSupply = totalSupply.add(newTokens);
    require(_receiver != 0x0);
    balances[_receiver] = balances[_receiver].add(newTokens);
    emit Transfer(address(0), _receiver, newTokens);
    return true;
  }

  /**
   * @dev Transfer token for a specified address when not paused
   * @param _to The address to transfer to.
   * @param _value The amount to be transferred.
   */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    return super.transfer(_to, _value);
  }

  /**
   * @dev Transfer tokens from one address to another when not paused
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
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
  function allowance(address _owner, address _spender) public constant returns (uint256) {
    return super.allowance(_owner,_spender);
  }

}

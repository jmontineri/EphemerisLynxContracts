pragma solidity ^ 0.4 .7;

contract Owned {
  address public owner;

  function Owned() {
    owner = msg.sender;
  }
  
  modifier onlyowner() {
    if (msg.sender == owner) _;
  }
}

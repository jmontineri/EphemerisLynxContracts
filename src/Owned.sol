pragma solidity ^ 0.4 .7;

contract Owned {
  address public owner;

  function Owned() {
    owner = msg.sender;
  }

  function changeOwner(address newOwner) onlyowner {
    owner = newOwner;
  }
  
  modifier onlyowner() {
    if (msg.sender == owner) _;
  }
}

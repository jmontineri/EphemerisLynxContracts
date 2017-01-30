pragma solidity ^ 0.4 .7;

contract Owned {
  address owner;

  function Owned() {
    owner = msg.sender;
  }

  function changeOwner(address newOwner) onlyowner {
    owner = newOwner;
  }
  
  function getOwner() constant returns (address){
    return owner;
  }
  
  modifier onlyowner() {
    if (msg.sender == owner) _;
  }
}

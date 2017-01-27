pragma solidity ^0.4.7;
import "Owned.sol";
contract mortal is Owned {
  function kill() onlyowner {
    if (msg.sender == owner) suicide(owner);
  }
}

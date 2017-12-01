pragma solidity ^0.4.7;
import "ID.sol";
import "IDController.sol";
import "Owned.sol";

contract Registry is Owned{

  mapping (address => address) public ids;
  mapping (address => address) reverseIds;         

  function setAddress(ID idAddress){

    address ownerAddress = IDController(idAddress.owner()).owner();
    if(tx.origin == ownerAddress){
      address previousOwner = reverseIds[address(idAddress)];
      reverseIds[address(idAddress)] = tx.origin;
      delete ids[previousOwner];
      ids[tx.origin] = address(idAddress);
    }
  }
}

pragma solidity ^0.4.7;
import "ID.sol";
import "IDController.sol";
import "Owned.sol";

contract Registry is Owned{

  mapping (address => address) public ids;
  mapping (address => address) reverseIds;         

  function setAddress(ID idAdress){

    address ownerAddress = IDController(idAdress.owner()).owner();
    address IDCAddress = idAdress.owner();
    if(tx.origin == ownerAddress){
      address previousOwner = reverseIds[address(idAdress)];
      reverseIds[address(idAdress)] = tx.origin;
      delete ids[previousOwner];
      ids[tx.origin] = address(idAdress);
    }
  }
}

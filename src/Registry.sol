pragma solidity ^0.4.7;
import "ID.sol";
import "IDController.sol";

contract Registry {
  mapping (address => address) public ids;
  mapping (address => address) reverseIds;         

  function SetAddress(ID idAdress){

    address ownerAddress = IDController(idAdress.owner()).owner();
    if(msg.sender == ownerAddress){
      address previousOwner = reverseIds[address(idAdress)];
      reverseIds[address(idAdress)] = msg.sender;
      delete ids[previousOwner];
      ids[msg.sender] = address(idAdress);
    }
  }
}

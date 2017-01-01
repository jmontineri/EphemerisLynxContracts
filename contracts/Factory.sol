pragma solidity ^0.4.2;
import "std.sol";
import "ID.sol";
contract Factory is owned {
    function createID() returns (address){
        ID newID = new ID();
        newID.changeOwner(msg.sender);
        return newID;
    }
}


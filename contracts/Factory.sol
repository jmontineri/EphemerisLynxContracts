pragma solidity ^0.4.2;
import "std.sol";
import "ID.sol";
import "IDController.sol";

contract Factory is owned {
    function createID() returns (IDController){
        ID newID = new ID();
        newID.changeOwner(msg.sender);
        return  createIDController(newID, msg.sender);
    }
    
    function createIDController (ID id, address sender) private returns (IDController){
        IDController idController = new IDController(id);
        id.changeOwner(idController);
        idController.changeOwner(sender);
        return idController;
    }
}


pragma solidity ^0.4.7;
import "owned.sol";
import "ID.sol";
import "IDController.sol";

contract Factory is owned {
    event ReturnIDController(address indexed _from, address _controllerAddress);
    function createID() returns (IDController){
        ID newID = new ID();
        newID.changeOwner(msg.sender);
        IDController idController = createIDController(newID, msg.sender);

        //Fire event returning the address of the IDController
        ReturnIDController(msg.sender, idController);
        return  idController;
    }

    function createIDController (ID id, address sender) private returns (IDController){
        IDController idController = new IDController(id);
        id.changeOwner(idController);
        idController.changeOwner(sender);
        return idController;
    }
}

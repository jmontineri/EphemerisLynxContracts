pragma solidity ^0.4.7;
import "Owned.sol";
import "ID.sol";
import "IDController.sol";
import "Registry.sol";

contract Factory is Owned {

    event ReturnIDController(address indexed _from, address _controllerAddress);
    Registry public registry;

    function Factory(){
        setRegistry(new Registry());
    }

    function setRegistry (Registry newRegistry) onlyowner{
        registry = newRegistry;
    }
    
    function createID() returns (IDController){
        ID newID = new ID();
        IDController idController = createIDController(newID, msg.sender);

        //Fire event returning the address of the IDController
        ReturnIDController(msg.sender, idController);
        registry.setAddress(newID);
        return idController;
    }

    function createIDController (ID id, address sender) private returns (IDController){

        IDController idController = new IDController(id);
        id.changeOwner(idController);

        idController.changeOwner(sender);
        idController.setRegistry(registry);

        return idController;
    }
}

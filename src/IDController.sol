pragma solidity ^ 0.4 .7;
import "Owned.sol";
import "ID.sol";
import "Watchdog.sol";
import "Attribute.sol";

contract IDController is Owned {
    ID id;
    Watchdog watchdogs;

    function IDController(ID _id) {
        id = _id;
    }

    function removeAttribute(bytes32 key) onlyowner returns(Attribute) {
        return id.removeAttribute(key);
    }

    function removeAllAttributes() onlyowner {
        id.removeAllAttributes();
    }

    function addAttribute(bytes32 key, Attribute attr) onlyowner returns(bool) {
        return id.addAttribute(key, attr);
    }

    function getAttribute(bytes32 key) returns(Attribute) {
        return id.getAttribute(key);
    }

    function deleteID() onlyowner {
        id.kill();
        selfdestruct(owner);
    }
    
    function getWatchDogs() returns (Watchdog){
        return watchdogs;
    }
    
    function getID() returns (ID){
        return id;
    }
    
    function setWatchDogs(Watchdog newContract) onlyowner {
        watchdogs = newContract;
    }
    
    function changeOwner(address newOwner) onlyowner {
        owner = newOwner;
    }
    
    modifier onlyowner() {
        if (msg.sender == owner || msg.sender == address(watchdogs)) _;
    }
}

pragma solidity ^ 0.4 .7;
import "Owned.sol";
import "ID.sol";

contract IDController is Owned {
    ID id;
    address watchdog;

    function IDController(ID _id) {
        id = _id;
        wa
    }

    function removeAttribute(bytes32 key) onlyowner returns(Attribute) {
        return id.removeAttribute(key);
    }

    function removeAllAttributes() onlyowner {
        id.removeAllAttributes();
    }

    function addAttribute(bytes32 key, string attrLocation) onlyowner returns(Attribute) {
        return id.addAttribute(key, attrLocation);
    }

    function getAttribute(bytes32 key) returns(Attribute) {
        return id.getAttribute(key);
    }

    function deleteID() onlyowner {
        id.kill();
        if (msg.sender == owner) suicide(owner);
    }

    function changeWatchDogContract(address newContract) onlyowner {
        watchdog = newContract;
    }
    
    modifier onlyowner() {
        if (msg.sender == owner || msg.sender == watchdog) _;
    }
}

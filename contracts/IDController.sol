pragma solidity ^0.4.7;
import "std.sol";
import "ID.sol";

contract IDController is owned {
    ID id;
    function IDController(ID _id){
        id = _id;
    }
    function removeAttribute(bytes32 key) onlyowner returns (Attribute){
        return id.removeAttribute(key);
    }

    function removeAllAttributes() onlyowner{
       id.removeAllAttributes();
    }

    function addAttribute(bytes32 key, string attrLocation) onlyowner returns (Attribute){
        return id.addAttribute(key, attrLocation);
    }

    function getAttribute(bytes32 key) returns (Attribute){
        return id.getAttribute(key);
    }

    function deleteID() onlyowner{
        id.kill();
        if (msg.sender == owner) suicide(owner);
    }
}

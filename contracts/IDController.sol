pragma solidity ^0.4.2;
import "std.sol";
import "ID.sol";

contract IDController is owned {
    ID id;
    function IDController(ID _id){
        id = _id;    
    }
    function removeAttribute(bytes32 key) onlyowner returns (string){
        return id.removeAttribute(key);
    }
    
    function removeAllAttributes() onlyowner{
       id.removeAllAttributes();
    }
    
    function addAttribute(bytes32 key, string attrLocation) onlyowner returns (string){
        return id.addAttribute(key, attrLocation);
    }
    
    function getAttributeLocation(bytes32 key) returns (string){
        return id.getAttributeLocation(key);
    }
    
    function deleteID() onlyowner{
        id.kill();
        if (msg.sender == owner) suicide(owner);
    }
}
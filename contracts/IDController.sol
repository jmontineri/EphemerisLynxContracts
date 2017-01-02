pragma solidity ^0.4.2;
import "std.sol";
import "ID.sol";

contract IDController is owned {
    ID id;
    string name;
    function IDController(ID _id){
        id = _id;    
        name = "hello";
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
pragma solidity ^0.4.2;
import "std.sol";

contract ID is mortal{
    mapping (string => string) attributes;
    
    function addAttribute(string type, string attrLocation) onlyowner returns (string){
        attributes[type] = attrLocation;
        return attributes[type];
    }
    
    function getAttribute(string type) returns (string){
        return attributes[type];
    }
    
    function removeAttribute(string type) returns (string){
        string retValue = attributes[type];
        
        //remove value
        attributes[type] = "";
        
        return retValue;
    }
}
pragma solidity ^0.4.2;
import "std.sol";

contract ID is mortal{
    mapping (string => string) attributes;
    
    function addAttribute(string key, string attrLocation) onlyowner returns (string){
        attributes[key] = attrLocation;
        return attributes[key];
    }
    
    function getAttribute(string key) returns (string){
        return attributes[key];
    }
    
    function removeAttribute(string key) returns (string){
        string retValue = attributes[key];
        
        //remove value
        attributes[key] = "";
        
        return retValue;
    }
}
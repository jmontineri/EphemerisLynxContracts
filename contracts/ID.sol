pragma solidity ^0.4.2;
import "std.sol";
import "strings.sol";

contract ID is mortal{
    using strings for *;
    mapping (bytes32 => string) attributes;
    bytes32[] storedAttributes;
    
    function addAttribute(bytes32 key, string attrLocation) onlyowner returns (string){
        attributes[key] = attrLocation;
        storedAttributes.push(key);
        return attributes[key];
    }
    
    function getAttribute(bytes32 key) returns (string){
        return attributes[key];
    }
    
    function removeAttribute(bytes32 key) returns (string){
        string retValue = attributes[key];
        
       // remove value
        attributes[key] = "";
        
        return retValue;
    }
    
    function removeAllAttributes(){
        bytes32 key;
        uint initialLength = storedAttributes.length;
        
        for(uint i=0; i<storedAttributes.length; i++){
            key = storedAttributes[i];
            removeAttribute(key);
            
            if(attributes[key].toSlice().len() != 0){
                throw;
            }
        }
        
        delete storedAttributes;
    }
}
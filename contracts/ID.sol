pragma solidity ^0.4.2;
import "std.sol";
import "strings.sol";

contract ID is mortal{
    using strings for *;
    mapping (bytes32 => string) attributes;
    bytes32[] storedAttributes;
    uint attrCount = 0;
    function addAttribute(bytes32 key, string attrLocation) onlyowner returns (string){
        attributes[key] = attrLocation;
        storedAttributes[attrCount]=key;
        attrCount++;
        return attributes[key];
    }
    
    function getAttribute(bytes32 key) returns (string){
        return attributes[key];
    }
    
    function removeAttribute(bytes32 key) returns (string){
        string retValue = attributes[key];
        
        //remove value
        attributes[key] = "";
        
        return retValue;
    }
    
    function removeAllAttributes() {
        bytes32 key;
        uint initialLength = storedAttributes.length;
        for(uint i=0;i<attrCount;i++){
            key = storedAttributes[i];
            removeAttribute(key);
            delete storedAttributes[i];
            if(attributes[key].toSlice().len() != 0 || storedAttributes.length!=initialLength-i){
                throw;
            }
        }
        attrCount=0;
    }
}
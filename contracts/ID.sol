pragma solidity ^0.4.2;
import "std.sol";
import "strings.sol";

contract ID is mortal{
    using strings for *;
    mapping (bytes32 => string) attributes;
    bytes32[] public attributesKeys;
    
    function addAttribute(bytes32 key, string attrLocation) onlyowner returns (string){
        attributes[key] = attrLocation;
        attributesKeys.push(key);
        return attributes[key];
    }
    
    function getAttributeLocation(bytes32 key) returns (string){
        return attributes[key];
    }
    
    function removeAttribute(bytes32 key) onlyowner returns (string){
        //todo: to reduce cost, try with storage variable
        var retValue = attributes[key].toSlice().copy().toString();
        
       // remove value
        attributes[key] = "";
        
        return retValue;
    }
    
    function removeAllAttributes() onlyowner{
        bytes32 key;
        uint initialLength = attributesKeys.length;
        
        for(uint i=0; i<attributesKeys.length; i++){
            key = attributesKeys[i];
            removeAttribute(key);
            
            if(attributes[key].toSlice().len() != 0){
                throw;
            }
        }
        
        delete attributesKeys;
    }
}
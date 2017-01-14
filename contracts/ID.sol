pragma solidity ^0.4.7;
import "mortal.sol";
import "strings.sol";
import "Attribute.sol";

contract ID is mortal{
    using strings for *;
    mapping (bytes32 => Attribute ) attributes;
    bytes32[] public attributesKeys;

    function addAttribute(bytes32 key, string attrLocation) onlyowner returns (Attribute){
        attributes[key] = new Attribute(attrLocation);
        attributesKeys.push(key);
        return attributes[key];
    }

    function getAttribute(bytes32 key) constant returns (Attribute){

        return attributes[key];
    }

    function removeAttribute(bytes32 key) onlyowner returns (Attribute){
        delete attributes[key];
        /*for(uint i = 0;i < attributesKeys.length;i++){
            if(attributesKeys[i]==key){
                remove(i);
            }
        }*/
        return attributes[key];
    }

    function removeAllAttributes() onlyowner{
        bytes32 key;
        uint initialLength = attributesKeys.length;

        for(uint i=0; i<attributesKeys.length; i++){
            key = attributesKeys[i];
            removeAttribute(key);

           /* if(attributes[key].toSlice().len() != 0){
                throw;
            }*/
        }

        delete attributesKeys;
    }
    
    /*function remove(uint index)  returns(bytes32[]) {
        if (index >= attributesKeys.length) return;

        for (uint i = index; i<attributesKeys.length-1; i++){
            attributesKeys[i] = attributesKeys[i+1];
        }
        delete attributesKeys[attributesKeys.length-1];
        attributesKeys.length--;
        return attributesKeys;
    }*/
}

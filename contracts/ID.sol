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

    function getAttribute(bytes32 key) returns (Attribute){
        return attributes[key];
    }

    function removeAttribute(bytes32 key) onlyowner returns (Attribute){
        //todo: to reduce cost, try with storage variable
        //var retValue = attributes[key].toSlice().copy().toString();

       // remove value
        delete attributes[key];

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
}

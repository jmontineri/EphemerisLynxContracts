pragma solidity ^0.4.7;
import "mortal.sol";
import "strings.sol";
import "Attribute.sol";

contract ID is mortal{
    using strings for *;
    mapping (bytes32 => Attribute ) public attributes;
    bytes32[] public attributesKeys;

    function addAttribute(bytes32 key, Attribute attr) onlyowner returns (bool){
        attributes[key] = attr;
        attributesKeys.push(key);
        return attributes[key] == attr;
    }

    function getAttribute(bytes32 key) constant returns (Attribute){

        return attributes[key];
    }
    
    function addCertificate(Attribute attr, Certificate cert){
        attr.addCertificate(cert);
    }

    function removeAttribute(bytes32 key) onlyowner returns (Attribute){
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
    
    function changeOwner(address newOwner) onlyowner {
        owner = newOwner;
    }
}

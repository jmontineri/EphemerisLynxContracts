pragma solidity ^0.4.7;
import "mortal.sol";
import "Attribute.sol";
import "Certificate.sol";

contract ID is mortal{
    mapping (bytes32 => Attribute ) public attributes;
    bytes32[] public attributesKeys;

    function addAttribute(bytes32 key, Attribute attr) onlyowner returns (bool){
        
        //if you are not the owner of the attribute you can't add it to your id
        if( attr.owner() != address(this))
            throw;
        
        attributes[key] = attr;
        attributesKeys.push(key);
        return attributes[key] == attr;
    }

    function getAttribute(bytes32 key) constant returns (Attribute){
        return attributes[key];
    }
    
    function addCertificate(bytes32 key, Certificate cert){
        addCertificate(getAttribute(key), cert);
    }
    
    function addCertificate(Attribute attr, Certificate cert){
        if(attr.owner() != address(this))
            throw;
        attr.addCertificate(cert);
    }

    function removeAttribute(bytes32 key) onlyowner{
        delete attributes[key];
    }

    //function removeAllAttributes()
    
    function changeOwner(address newOwner) onlyowner {
        owner = newOwner;
    }
    
    function createCertificate(string _location, string _hash, Attribute _owningAttribute) onlyowner returns (Certificate) {
        return new Certificate(_location, _hash, _owningAttribute);
    }
    
    function revokeCertificate(Certificate cert){
        cert.revoke();
    }
}

pragma solidity ^0.4.7;
import "mortal.sol";
import "Attribute.sol";
import "Certificate.sol";

contract ID is mortal{
    mapping (bytes32 => Attribute ) public attributes;
    bytes32[] public attributesKeys;

    event ReturnCertificate(
        address _from, 
        address _certAddress
    );

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
    
    function addCertificate(bytes32 key, Certificate cert) onlyowner{
        addCertificate(getAttribute(key), cert);
    }
    
    function addCertificate(Attribute attr, Certificate cert){
        if(attr.owner() != address(this))
            throw;
        attr.addCertificate(cert);
    }

    function getCertificate(bytes32 key, address issuer) constant returns (Certificate){
        return getAttribute(key).getCertificate(issuer);
    }

    function removeAttribute(bytes32 key) onlyowner{
        delete attributes[key];
    }

    //function removeAllAttributes()
    
    function changeOwner(address newOwner) onlyowner {
        owner = newOwner;
    }
    
    function createCertificate(string _location, string _hash, Attribute _owningAttribute) onlyowner returns (Certificate) {
        Certificate cert = new Certificate(_location, _hash, _owningAttribute);
        ReturnCertificate(msg.sender, address(cert));
        return cert;
    }
    
    function revokeCertificate(Certificate cert){
        cert.revoke();
    }
}

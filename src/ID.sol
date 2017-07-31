pragma solidity ^0.4.7;
import "mortal.sol";
import "Attribute.sol";
import "Certificate.sol";
import "Storage.sol";

contract ID is mortal{

    Storage attributeStorage;

    event ReturnCertificate(
        address indexed _issuingAddress, 
        address indexed _associatedAttribute, 
        address _certAddress
    );

    function ID(){
        attributeStorage = new Storage();
    }

    function attributeCount() constant returns (uint256){
        return attributeStorage.length();
    }

    function addAttribute(bytes32 key, Attribute attr) onlyowner returns (bool){
        
        //if you are not the owner of the attribute you can't add it to your id
        if( attr.owner() != address(this))
            throw;
        
        attributeStorage.add(key, attr);
        return attributeStorage.getByKey(key) == address(attr);
    }

    function getAttribute(bytes32 key) constant returns (Attribute){
        return Attribute(attributeStorage.getByKey(key));
    }
    function getAttributeByIndex(uint256 index) constant returns (Attribute){
        return Attribute(attributeStorage.getByIndex(index));
    }
    
    function addCertificate(bytes32 key, Certificate cert) onlyowner{
        addCertificate(getAttribute(key), cert);
    }
    
    function addCertificate(Attribute attr, Certificate cert) onlyowner{
        if(attr.owner() != address(this))
            throw;
        attr.addCertificate(cert);
    }

    function removeAttribute(bytes32 key) onlyowner{
        attributeStorage.remove(key);
    }

    //function removeAllAttributes()
    
    function changeOwner(address newOwner) onlyowner {
        owner = newOwner;
    }
    
    function createCertificate(string _location, string _hash, Attribute _owningAttribute) onlyowner returns (Certificate) {
        Certificate cert = new Certificate(_location, _hash, _owningAttribute);
        ReturnCertificate(msg.sender, _owningAttribute, address(cert));
        return cert;
    }
    
    function revokeCertificate(Certificate cert){
        cert.revoke();
    }
}

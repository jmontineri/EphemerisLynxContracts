pragma solidity ^0.4.7;
import "Owned.sol";
import "Certificate.sol";
import "Storage.sol";

contract Attribute is Owned{
    string public location;
    string public hash;
    //Array of keys to iterate over the mapping

    Storage certStorage;


    function Attribute(string _location, string _hash, address _owner){
        location = _location;
        hash = _hash;
        owner = _owner;
        certStorage = new Storage();
    }
    
    function certificateCount() constant returns (uint256){
        return certStorage.length();
    }
    
    function addCertificate(Certificate _cert) onlyowner{
        //check the certificate is really for this id
        if(_cert.owningAttribute() != this)
            throw;
        //maker sure the the one adding is the issuer
        //if(_cert.owner() != msg.sender)
            //throw;
        certStorage.add(bytes32(_cert.owner()), _cert);
    }
    
    function getCertificate(address _issuer) constant returns (Certificate){
        return Certificate(certStorage.getByKey(bytes32(_issuer)));
    }

    
    function getCertificateByIndex(uint256 index) constant returns(Certificate){
        return Certificate(certStorage.getByIndex(index));
    }
}

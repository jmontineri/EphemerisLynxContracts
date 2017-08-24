pragma solidity ^0.4.7;
import "Owned.sol";
import "Certificate.sol";
import "DLinkedListStorage.sol";

contract Attribute is Owned{
    string public location;
    string public hash;

    DLinkedListStorage public certStorage;


    function Attribute(string _location, string _hash, address _owner){
        location = _location;
        hash = _hash;
        owner = _owner;
        certStorage = new DLinkedListStorage();
    }
    
    function certificateCount() constant returns (uint256){
        return certStorage.item_count();
    }
    
    function addCertificate(Certificate _cert) onlyowner{
        //check the certificate is really for this id
        if(_cert.owningAttribute() != this)
            throw;
        certStorage.add(bytes32(_cert.owner()), _cert);
    }
    
    function getCertificate(address _issuer) constant returns (Certificate){
        return Certificate(certStorage.getByKey(bytes32(_issuer)));
    }
}

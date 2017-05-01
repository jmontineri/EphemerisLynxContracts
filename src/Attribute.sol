pragma solidity ^0.4.7;
import "Owned.sol";
import "Certificate.sol";

contract Attribute is Owned{
    string public location;
    string public hash;
    mapping (address => Certificate ) public certificates;
    //Array of keys to iterate over the mapping
    address[] public certificateKeys;

    function Attribute(string _location, string _hash, address _owner){
        location = _location;
        hash = _hash;
        owner = _owner;
    }
    
    function addCertificate(Certificate _cert) onlyowner{
        //check the certificate is really for this id
        if(_cert.owningAttribute() != this)
            throw;
        //maker sure the the one adding is the issuer
        //if(_cert.owner() != msg.sender)
            //throw;
            
        certificates[_cert.owner()] = _cert;
        certificateKeys.push(_cert.owner());
    }
    
    function getCertificate(address _issuer) returns (Certificate){
        return certificates[_issuer];
    }
}

pragma solidity ^0.4.7;
import "Owned.sol";
contract Attribute is Owned{
    string public location;
    mapping (address => Certificate ) public certificates;
    //Array of keys to iterate over the mapping
    address[] public certificateKeys;

    function Attribute(string _location){
        setLocation(_location);
    }

    function setLocation(string _location) onlyowner{
        location = _location;
    }
    
    function addCertificate(Certificate _cert) onlyowner{
        //check the certificate is really for this id
        if(_cert.owningAttribute != this)
            throw;
        //maker sure the the one adding is the issuer
        if(_cert.owner != msg.sender)
            throw;
            
        certificates[_cet.owner] = _cert;
        certificateKeys.push(_cet.owner);
        
    }
    
    function getCertificate(address issuer) returns (Certificate){
        return certificates[issuer];
    }
}

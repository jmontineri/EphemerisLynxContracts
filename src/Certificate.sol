pragma solidity ^0.4.7;
import "Owned.sol";
contract Certificate is Owned{
    string public location;
    string public hash;
    bool public revoked = false;
    Attribute public owningAttribute
    //TODO: add expiration
    
    function Certificate(string _location, string _hash, Attribute _owningAttribute){
        location = _location;
        hash = _hash;
        owningAttribute = _owningAttribute;
    }
    
    function revoke() onlyowner {
        revoked = true;
    }
}
pragma solidity ^0.4.7;
import "Owned.sol";
import "Attribute.sol";

contract Certificate is Owned{
    string public location;
    string public hash;
    bool public revoked = false;
    Attribute public owningAttribute;
    event Revoked(address _sender);
    //TODO: add expiration
    
    function Certificate(string _location, string _hash, Attribute _owningAttribute){
        location = _location;
        hash = _hash;
        owningAttribute = _owningAttribute;
    }
    
    function revoke() onlyowner {
        revoked = true;
        Revoked(msg.sender);
    }
}

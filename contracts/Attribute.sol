pragma solidity ^0.4.7;
import "Owned.sol";
contract Attribute is Owned{
    string private location;

    function Attribute(string _location){
        setLocation(_location);
    }

    function setLocation(string _location) onlyowner{
        location = _location;
    }

    function getLocation() constant returns (string){
        return location;
    }
}

pragma solidity ^0.4.7;
import "std.sol";
contract Attribute is owned{
    string location;

    function Attribute(string _location){
        setLocation(_location);
    }

    function setLocation(string _location) onlyowner{
        location = _location;
    }

    function getLocation() returns (string){
        return location;
    }
}

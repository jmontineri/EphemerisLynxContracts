pragma solidity ^0.4.7;
import "owned.sol";
contract Attribute is owned{
    string aLocation;
    address public owner;
    function Attribute(string _location){
        setLocation(_location);
        owner = msg.sender;
    }

    function setLocation(string _location) onlyowner{
        aLocation = _location;
    }

    function getLocation() constant returns (string){
        return aLocation;
    }
}

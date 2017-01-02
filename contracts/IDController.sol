pragma solidity ^0.4.2;
import "std.sol";
import "ID.sol";

contract IDController is owned {
    ID id;
    string name;
    function IDController(ID _id){
        id = _id;    
        name = "hello";
    }
}
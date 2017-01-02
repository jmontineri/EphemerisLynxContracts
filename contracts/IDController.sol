pragma solidity ^0.4.2;
import "std.sol";
import "ID.sol";

contract IDController is owned {
    ID id;
    function IDController(ID _id){
        id = _id;    
    }
    function removeAttribute(bytes32 key) onlyowner returns (string){
        return id.removeAttribute(key);
    }
    
    function removeAllAttributes() onlyowner{
       id.removeAllAttributes();
    }
}
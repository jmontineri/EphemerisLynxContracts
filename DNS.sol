//This contract is a simple DNS
pragma solidity ^0.4.2;
import "std.sol";

contract DNS {
   mapping(string => address) database;
   
    function register(string domain) returns (bool){
        
        if(database[domain] == address(0x0)){
            database[domain] = msg.sender;
            return true;
        }
        
        return false;
    }
    
    function transfert(string domain, address newOwner) returns (bool){
        
        if((database[domain] != address(0x0)) && (database[domain] == msg.sender)){
            database[domain] = newOwner;
            return true;
        }
        
        return false;
    }
    
    function getAddress(string domain) returns (address){
        return database[domain];
    }
}
//This contract is a simple DNS
pragma solidity ^0.4.2; //define the compiler version

contract DNS {
    //a mapping is like a hash table, here the key is a string and value is an address
    mapping (string => address) database;
    
    //This function allows the message send (person who sent the transaction)
    //to associate an arbitrary string with the public key
    function register(string domain) returns (bool){
        
        if(database[domain] == address(0x0)){ //we check if the value for key domain is the zero value of type address (aka we check if its null)
            database[domain] = msg.sender; // if it is we assign the pub key of the sender to the domain string
            return true;
        }
        
        return false;
    }
    
    //This function allows the owner of a domain to transfer it to an other owner
    function transfert(string domain, address newOwner) returns (bool){
        
        //We check if the address for the given domain is set and if it correspond 
        //to the pub key of the person who called this function (msg.sender)
        if((database[domain] != address(0x0)) && (database[domain] == msg.sender)){
            //if it corresponds then the msg.sender is the owner of the domain and we allow the transfer
            database[domain] = newOwner;
            return true;
        }
        
        return false;
    }
    
    //Given a domain, this function return the address register to it
    function getAddress(string domain) returns (address){
        return database[domain];
    }
}
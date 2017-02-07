pragma solidity ^0.4.7;
import "MultiOwned.sol";
import "IDController.sol";
contract Watchdog is MultiOwned {
    
    // pending transaction we have at present.
    Proposal public proposal;
    
    // TYPES

    // Proposal structure to remember details of transaction lest it need be saved for a later call.
    struct Proposal {
        IDController callDestination;
        //uint value;
        //bytes data;
        address newOwner;
        address initiator;
        bytes32 hash; //hash communicated to the other watchdog. 
                    //Ensures that if the proposal changes by the time the 
                    //watchdog votes. He won't be able to cast a vote
    }
    
    //EVENTS
    event NewProposal(bytes32 operation, address initiator, address to, address newOwner);
    event ProposalConfirmed(bytes32 operation, address initiator, address lastSignatory, address to, address newOwner);

    // METHODS

    // constructor - just pass on the owner array to the multiowned
    function Watchdog(address[] _owners, uint _required)
            MultiOwned(_owners, _required) {
    }
    
    // Outside-visible transact entry point. Executes transaction using multisig process. 
    // We provide a hash on return to allow the sender to provide
    // shortcuts for the other confirmations (allowing them to avoid replicating the _to, _value
    // and _data arguments).
    /*function propose(IDController _callDestination, uint _value, bytes _data) external onlyoneowner returns (bytes32 _r) {
        
        // determine our operation hash.
        _r = sha3(msg.data, block.number);
        
        //if there is no current proposal
        if (proposal.hash == 0) {
            proposal = Proposal(_callDestination, _value, _data, msg.sender, _r);
            ConfirmationNeeded(_r, msg.sender, _value, _callDestination, _data);
        }
    }*/
    
    function proposeMigration(IDController _callDestination, address newOwner) onlyoneowner returns (bytes32){
    
        //if there is no current proposal
        if (proposal.hash == 0) {
            // determine our operation hash.
            bytes32 _r = sha3(msg.data, block.number);
            proposal = Proposal(_callDestination, newOwner, msg.sender, _r);
            NewProposal(_r, msg.sender, _callDestination, newOwner);
            confirm(proposal.hash);
            return proposal.hash;
        } else
            return 0;
    }
    
    
    function proposeDeletion(IDController _callDestination) onlyoneowner returns (bytes32 _r){
        return proposeMigration(_callDestination, 0);
    }
    
    // confirm a transaction through just the hash
    function confirm(bytes32 _h) onlymanyowners(_h) returns (bool) {
        
        if(proposal.hash != _h)
            throw;
        
        if (address(proposal.callDestination) != 0) {
            
            //if we have a deletion proposal
            if(proposal.newOwner == 0)
                proposal.callDestination.deleteID(); //delete the ID
            else
                proposal.callDestination.changeOwner(proposal.newOwner); //if not migrate the id
                
            ProposalConfirmed(proposal.hash, proposal.initiator, msg.sender, proposal.callDestination, proposal.newOwner);
            delete proposal;
            return true;
        }else
            throw;
    }
    
    // cancel a transaction through just the hash
    function cancel(bytes32 _h) onlyoneowner returns (bool) {
        
        if(proposal.hash != _h)
            throw;
        
        //make sure only the initiator can cancel the proposal
        if (proposal.initiator == msg.sender) {
            clearPending();
            return true;
        }else
            return false;
    }
    
    function getProposal() constant returns (IDController, address, address, bytes32){
                IDController callDestination;
        //uint value;
        //bytes data;
        address newOwner;
        address initiator;
        bytes32 hash;
        
        return (proposal.callDestination, proposal.newOwner, proposal.initiator, proposal.hash);
    }
    
    // INTERNAL METHODS
    function clearPending() internal {
        delete proposal;
        super.clearPending();
    }
    
}
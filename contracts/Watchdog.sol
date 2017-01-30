pragma solidity ^0.4.7;
import "MultiOwned.sol";
import "IMultisig.sol";
contract Watchdog is IMultisig, MultiOwned {
    
    // pending transaction we have at present.
    Proposal proposal;
    
    // TYPES

    // Proposal structure to remember details of transaction lest it need be saved for a later call.
    struct Proposal {
        address destination;
        uint value;
        bytes data;
        address initiator;
        bytes32 hash; //hash communicated to the other watchdog. 
                    //Ensures that if the proposal changes by the time the 
                    //watchdog votes. He won't be able to cast a vote
    }

    // METHODS

    // constructor - just pass on the owner array to the multiowned
    function Watchdog(address[] _owners, uint _required)
            MultiOwned(_owners, _required) {
    }
    
    // Outside-visible transact entry point. Executes transaction using multisig process. 
    // We provide a hash on return to allow the sender to provide
    // shortcuts for the other confirmations (allowing them to avoid replicating the _to, _value
    // and _data arguments).
    function propose(address _destination, uint _value, bytes _data) external onlyoneowner returns (bytes32 _r) {

        // determine our operation hash.
        _r = sha3(msg.data, block.number);
        
        //if there is no current proposal
        if (proposal.hash == 0) {
            proposal = Proposal(_destination, _value, _data, msg.sender, _r);
            ConfirmationNeeded(_r, msg.sender, _value, _destination, _data);
        }
    }
    
    // confirm a transaction through just the hash
    function confirm(bytes32 _h) onlymanyowners(_h) returns (bool) {
        
        if(proposal.hash != _h)
            throw;
        
        if (proposal.destination != 0) {
            
            ///////// Attemp to forward the transaction /////////
            // Note: If a contract tries to CALL or CREATE a contract with either
    	    // (i) insufficient balance, or (ii) stack depth already at maximum (1024),
        	// the sub-execution and transfer do not occur at all, no gas gets consumed, and 0 is added to the stack.
    	    // see: https://github.com/ethereum/wiki/wiki/Subtleties#exceptional-conditions
            if(!proposal.destination.call.value(proposal.value)(proposal.data))
                throw;
                
            MultiTransact(msg.sender, proposal.hash, proposal.value, proposal.destination, proposal.data);
            delete proposal;
            return true;
        }else
            return false;
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
    
    // INTERNAL METHODS
    function clearPending() internal {
        delete proposal;
        super.clearPending();
    }
    
}
pragma solidity ^0.4.7;
import "dapple/test.sol"; // virtual "dapple" package imported when `dapple test` is run
import "Watchdog.sol";
import "Factory.sol";
import "IDController.sol";
import "ID.sol";

contract WatchdogTest is Test {
    Factory factory;
    IDController idCtrl;
    Watchdog watchdog;
    //proxy contract to send call as a second actor. The first actor is the
    //current contract
    WatchDogTestProxy actor2;
    
    function setUp() {
        factory = new Factory();
        idCtrl = factory.createID();
        watchdog = new Watchdog(new address[](0), 2);
        
        if(watchdog.m_numOwners() != 1)
            throw;
        if(watchdog.m_required() != 2)
            throw;
        
        idCtrl.setWatchDogs(watchdog);
        
        actor2 = new WatchDogTestProxy(watchdog);
        //add the second actor as an authorised watchdog 
        watchdog.addMultisigOwner(actor2);
    }
    
    function testProposeMigration() returns (bytes32 proposalHash){
        //assert current owner is this contract
        assertEq(idCtrl.owner(), this);
        //first watchdog (this) issue proposal
        proposalHash = watchdog.proposeMigration(idCtrl, actor2);
        // ensure that the proposal was created
        assertFalse(proposalHash == 0);
        // since we issue the proposal we (this) should have confirmed
        assertTrue(watchdog.hasConfirmed(proposalHash, this));
        //TODO: test events
    }
    
    function testProposeDeletion() returns (bytes32 proposalHash){
        //first watchdog issue proposal
        proposalHash = watchdog.proposeDeletion(idCtrl);
        // ensure that the proposal was created
        assertFalse(proposalHash == 0);
        // since we issue the proposal we (this) should have confirmed
        assertTrue(watchdog.hasConfirmed(proposalHash, this));
        //TODO: test events
        //TODO: test an for the new owner with address 0
    }
    
    function testConfirmMigration() {
        //first watchdog (this) issue proposal
        bytes32 proposalHash = testProposeMigration();
        //make sure we (this) can't confirm again
        assertFalse(watchdog.confirm(proposalHash));
        //make sure actor 2 hasnt confirm
        assertFalse(watchdog.hasConfirmed(proposalHash, actor2));
        //actor 2 confirms, since have a m_required of 2 the operation should execute
        assertTrue(actor2.confirm(proposalHash));
        //the new owner should be actor2
        assertEq(idCtrl.owner(), actor2);
        //TODO: test events
    }
    
    function testConfirmDeletion() {
        //first watchdog (this) issue proposal
        bytes32 proposalHash = testProposeDeletion();
        //make sure we can't confirm again
        assertFalse(watchdog.confirm(proposalHash));
        //make sure actor 2 hasnt confirm
        assertFalse(watchdog.hasConfirmed(proposalHash, actor2));
        //actor 2 confirms, since have a m_required of 2 the operation should execute
        assertTrue(actor2.confirm(proposalHash));
        //TODO: test call on suicided contract
    }
    
    function testCancel() {
        //first watchdog (this) issue proposal
        bytes32 proposalHash = testProposeMigration();
        //only the initiator (this) can cancel
        assertFalse(actor2.cancel(proposalHash));
        assertTrue(watchdog.cancel(proposalHash));
        //actor 2 tries to confirm, should fail cause it has been cancelled
        assertFalse(actor2.confirm(proposalHash));
        //make sure the proposal was deleted
        var(callDestination, newOwner, initiator, hash) = watchdog.getProposal();
        assertEq32(hash, 0);
    }
    
    function testGetProposal() {
        //first watchdog (this) issue proposal
        bytes32 proposalHash = testProposeMigration();
        
        //make sure the current proposal is equal to the proposal we just made
        var(callDestination, newOwner, initiator, hash) = watchdog.getProposal();
        assertEq32(hash, proposalHash);
        assertEq(newOwner, actor2);
        assertEq(initiator, this);
        assertEq(callDestination, idCtrl);
        
    }
}

//This proxy contract will act as a second actor calling the watchdog contract
contract WatchDogTestProxy {
    Watchdog watchdog;
    
    function WatchDogTestProxy(Watchdog _watchdog) {
        watchdog = _watchdog;
    }
    
    function proposeMigration(IDController _callDestination, address newOwner) returns (bytes32 _r){
        return watchdog.proposeMigration(_callDestination, newOwner);
    }
    
    function proposeDeletion(IDController _callDestination) returns (bytes32 _r){
        return watchdog.proposeDeletion(_callDestination);
    }
    
    function confirm(bytes32 _h) returns (bool){
        return watchdog.confirm(_h);
    }
    
    function cancel(bytes32 _h) returns (bool){
        return watchdog.cancel(_h);
    }
}
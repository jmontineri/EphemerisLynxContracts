pragma solidity ^0.4.7;
import "dapple/test.sol"; // virtual "dapple" package imported when `dapple test` is run
import "Watchdog.sol";
import "Factory.sol";
import "IDController.sol";

contract WatchdogTest is Test {
    Factory factory;
    IDController idCtrl;
    Watchdog watchdog;
    
    function setUp() {
        factory = new Factory();
        idCtrl = factory.createID();
        watchdog = new Watchdog([], 1);
        idCtrl.setWatchDogs(watchdog);
    }
    
    function proposeTest() {
        
    }
    
    function confirmTest() {
        
    }
    
    function cancelTest() {
        
    }
    
    function clearPendingTest() {
        
    }
}

//This proxy contract will act as a second actor calling the watchdog contract
contract WatchDogTestProxy{
    Watchdog watchdog;
    
    function WatchDogTestProxy(Watchdog _watchdog){
        watchdog = _watchdog;
    }
    
    function propose(address _destination, uint _value, bytes _data) returns (bytes32 _r){
        return watchdog.propose(_destination, _value, _data);
    }
    
    function confirm(bytes32 _h) returns (bool){
        return watchdog.confirm(_h);
    }
}
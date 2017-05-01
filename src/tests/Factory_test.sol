pragma solidity ^0.4.7;
import "dapple/test.sol"; // virtual "dapple" package imported when `dapple test` is run
import "Attribute.sol";
import "Factory.sol";

contract FactoryTest is Test {
    Factory factory;
    
    function setUp() {
        factory = new Factory();
    }
    
    function testCreateID(){
        IDController idCtrl = factory.createID();
        ID id = idCtrl.getID();
        
        //ensure that current contract is the owner of the controller
        assertEq(this, address(idCtrl.owner()));
    }
}
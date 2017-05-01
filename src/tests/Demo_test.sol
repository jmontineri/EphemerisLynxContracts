pragma solidity ^0.4.7;
import "dapple/test.sol"; // virtual "dapple" package imported when `dapple test` is run
import "mortal.sol";
import "Attribute.sol";
import "Certificate.sol";
import "Factory.sol";
import "ID.sol";
import "IDController.sol";

contract DemoTest is Test{
    Factory factory;
    IDController idCtrl1;
    ID id1;
    
    function setUp() {
        factory = new Factory();
    }
    
    function testCreateID(){
        //create the ID, get the returned IDController
        idCtrl1 = factory.createID();
        
         //Get the actual ID from the controller
        id1 = idCtrl1.getID();
        
        assertEq(this, address(idCtrl1.owner()));
        
        assertEq(address(idCtrl1), address(id1.owner()));
    }
}
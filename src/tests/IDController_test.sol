pragma solidity ^0.4.7;
import "dapple/test.sol"; // virtual "dapple" package imported when `dapple test` is run
import "mortal.sol";
import "Attribute.sol";
import "Certificate.sol";
import "Factory.sol";
import "Watchdog.sol";
import "ID.sol";
import "IDController.sol";

contract IDControllerTest is Test{
    ID id1;
    IDController controller;
    Attribute attr;
    Certificate cert;
    DummyOwner newOwner;
    Watchdog watchdog;
    bytes32 key;
    
    function setUp() {
        id1 = new ID();
        controller = new IDController(id1);
        id1.changeOwner(controller);
        attr = new Attribute("test attr", "5678", id1);
        newOwner = new DummyOwner();
        watchdog = new Watchdog(new address[](0), 2);
        key = sha3("hello");
    }
    
    function testGetID(){
        assertEq(controller.getID(), id1);
    }

    function testDeleteID(){
        controller.deleteID();
        //When a contract selfdestructs, all values should be set to 0. This doesn't seem to work yet.
        //TODO: Make this work
        assertEq(id1.owner(), 0);
        assertEq(controller.owner(), 0);
    }

    function testSetAndGetWatchDogs(){
        //setting watchdogs and checking if it has been set correctly
        controller.setWatchDogs(watchdog);
        assertEq(controller.getWatchDogs(), watchdog);
    }

    function testAddAndGetAttribute(){
        
        //Adding attribute to ID through controller
        controller.addAttribute(key, attr);
        assertEq(controller.getAttribute(key), attr);
        //Make sure ID is the owner of the attribute
        assertEq(controller.getAttribute(key).owner(), address(id1));
    }

    function testAddAndRemoveAttribute(){
        //Adding attribute to ID, again      
        controller.addAttribute(key, attr);
        assertEq(controller.getAttribute(key), attr);
        //Removing attribute from ID - should not be equal any more
        controller.removeAttribute(key);
        assertFalse(controller.getAttribute(key) == attr);
    }

    function testChangeOwner(){
        controller.changeOwner(newOwner);
        assertEq(newOwner, controller.owner());
    }

    function testCreateCertificate(){
        //Creating attribute and cert for that attribute
        controller.addAttribute(key, attr);
        Certificate newCert = controller.createCertificate("created certificate", "2323", attr);
        //Making sure the new cert belongs to the ID that created it
        assertEq(newCert.owner(), id1);
        assertFalse(newCert.revoked());
        controller.revokeCertificate(newCert);
        assertTrue(newCert.revoked());
    }
}
//Dummy contract to set as new owner.
contract DummyOwner{
}

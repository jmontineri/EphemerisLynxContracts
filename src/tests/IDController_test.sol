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
    ID ownedID;
    ID nonOwnedID;
    
    IDController ownedController;
    IDController nonOwnedController;

    Attribute ownedAttribute;
    Attribute nonOwnedAttribute;
    Certificate cert;
    DummyOwner newOwner;
    Watchdog watchdog;
    bytes32 key;
    
    function setUp() {
        newOwner = new DummyOwner();

        ownedID = new ID();
        ownedController = new IDController(ownedID);
        ownedID.changeOwner(ownedController);

        nonOwnedController = newOwner.createIDController();
        nonOwnedID = newOwner.getID();
        
        ownedAttribute = new Attribute("test attribute", "5678", ownedID);
        nonOwnedAttribute = new Attribute("test attribute not owned", "5676", nonOwnedID);
        cert = new Certificate ("test certificate please ignore", "1234", ownedAttribute);
        watchdog = new Watchdog(new address[](0), 2);
        key = sha3("hello");
    }

    function testAddAttributeNotOwner(){
        nonOwnedController.addAttribute(key, nonOwnedAttribute);
        assertFalse(nonOwnedController.getAttribute(key) == nonOwnedAttribute);
    }

    function testRemoveAttributeNotOwner(){
        //Adding attribute as owner
        newOwner.addAttribute(key, nonOwnedAttribute);
        assertEq(nonOwnedController.getAttribute(key), nonOwnedAttribute);
        nonOwnedController.removeAttribute(key);
        assertEq(nonOwnedController.getAttribute(key), nonOwnedAttribute);
    }
    /*
    function testDeleteIDNotOwner(){
        nonOwnedController.deleteID();
        assertEq(nonOwnedController.getID(), nonOwnedID);
    }
    */
    function testSetWatchDogsNotOwner(){
        nonOwnedController.setWatchDogs(watchdog);
        assertFalse(nonOwnedController.getWatchDogs() == watchdog);
    }

    function testChangeOwnerNotOwner(){
        nonOwnedController.changeOwner(this);
        assertEq(nonOwnedController.owner(), newOwner);
    }

    function testGetID(){
        assertEq(ownedController.getID(), ownedID);
    }
    /*
    function testDeleteID(){
        ownedController.deleteID();
        //If ID is deleted, reference to it becomes null address (eg. 0x00..0)
        assertEq(ownedController.getID(), 0);
    }
    */

    function testAddAndGetCertificate(){
        //Adding ownedAttribute and cert to attribute by key
        ownedController.addAttribute(key, ownedAttribute);
        ownedController.addCertificate(key, cert);
        //Getting the certificate issued by this contract
        Certificate testedCert = ownedController.getAttribute(key).getCertificate(this);

        assertEq(testedCert, cert);
    }

    function testSetAndGetWatchDogs(){
        //setting watchdogs and checking if it has been set correctly
        ownedController.setWatchDogs(watchdog);
        assertEq(ownedController.getWatchDogs(), watchdog);
    }

    function testAddAndGetAttribute(){
        
        //Adding Attribute to ID through ownedController
        ownedController.addAttribute(key, ownedAttribute);
        assertEq(ownedController.getAttribute(key), ownedAttribute);
    }

    function testAddAndRemoveAttribute(){
        testAddAndGetAttribute();
        //Removing Attribute from ID - should not be equal any more
        ownedController.removeAttribute(key);
        assertFalse(ownedController.getAttribute(key) == ownedAttribute);
    }

    function testChangeOwner(){
        ownedController.changeOwner(newOwner);
        assertEq(newOwner, ownedController.owner());
    }

    function testCreateCertificate(){
        //Creating Attribute and cert for that Attribute
        ownedController.addAttribute(key, ownedAttribute);
        Certificate newCert = ownedController.createCertificate("created certificate", "2323", ownedAttribute);
        //Making sure the new cert belongs to the ID that created it
        assertEq(newCert.owner(), ownedID);
    }
 
    function testRevokeCertificate(){
        Certificate newCert = ownedController.createCertificate("created certificate", "2323", ownedAttribute);
        assertFalse(newCert.revoked());
        ownedController.revokeCertificate(newCert);
        assertTrue(newCert.revoked());
    }
}
//Dummy contract to set as new owner.
contract DummyOwner{
    IDController idc;
    ID id;

    function createIDController() returns (IDController){
        id = new ID();
        idc = new IDController(id);
        id.changeOwner(idc);
        return idc;
    }

    function createDummyCertificate(Attribute ownedAttribute) returns (Certificate){
        return new Certificate("test cert 2", "1234", ownedAttribute);
    }

    function addAttribute(bytes32 key, Attribute ownedAttribute){
        idc.addAttribute(key, ownedAttribute);
    }

    function getID() returns (ID){
        return id;
    }
}

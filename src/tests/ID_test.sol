pragma solidity ^0.4.7;
import "dapple/test.sol"; // virtual "dapple" package imported when `dapple test` is run
import "mortal.sol";
import "Attribute.sol";
import "Certificate.sol";
import "Factory.sol";
import "ID.sol";
import "IDController.sol";

contract IDTest is Test{
    ID ownedID;
    ID nonOwnedID;
    Attribute ownedAttribute;
    Attribute nonOwnedAttribute;
    Certificate cert;
    DummyOwner newOwner;
    bytes32 key;
    
    function setUp() {
        newOwner = new DummyOwner();
        ownedID = new ID();
        nonOwnedID = newOwner.createID();
	assertEq(nonOwnedID.owner(), newOwner);
        ownedAttribute = new Attribute("test attr", "5678", ownedID);
        nonOwnedAttribute = new Attribute("test ownedAttribute", "5678", nonOwnedID);
        cert = new Certificate("test cert", "1234", ownedAttribute);
        key = sha3("hello");

    }

    //operations that should not be possible unless you own the ID
    function testAddAttributeNotOwner(){
        nonOwnedID.addAttribute(key, ownedAttribute);
        assertFalse(nonOwnedID.getAttribute(key) == ownedAttribute);
    }

    function testRemoveAttributeNotOwner(){
        newOwner.addAttribute(key, nonOwnedAttribute);
        nonOwnedID.removeAttribute(key);
        assertEq(nonOwnedID.getAttribute(key), nonOwnedAttribute);
    }

    function testChangeOwnerNotOwner(){
        nonOwnedID.changeOwner(this);
        assertFalse(nonOwnedID.owner() == address(this));
    }

    function testAddAndGetAttribute(){
        
        //Adding ownedAttribute to ID        
        ownedID.addAttribute(key, ownedAttribute);
        assertEq(ownedID.getAttribute(key), ownedAttribute);
        //Make sure ID is the owner of the ownedAttribute
        assertEq(ownedID.getAttribute(key).owner(), address(ownedID));
    }

    function testThrowAddAttribute(){
        //Adding an ownedAttribute with the wrong owner should result in a failure
        ownedID.addAttribute(key, nonOwnedAttribute);
    }

    function testAddAndRemoveAttribute(){
	testAddAndGetAttribute();
        //Removing ownedAttribute from ID - should not be equal any more
        ownedID.removeAttribute(key);
        assertFalse(ownedID.getAttribute(key) == ownedAttribute);
    }

    function testAddCertificateByKey(){
        //Adding ownedAttribute and cert to attribute by key
        ownedID.addAttribute(key, ownedAttribute);
        ownedID.addCertificate(key, cert);
        //Getting the certificate issued by this contract
        Certificate testedCert = ownedID.getAttribute(key)
                                    .getCertificate(this);
        assertEq(testedCert, cert);
        //Test adding certificate without being owner
        Certificate cert2 = newOwner.createDummyCertificate(ownedAttribute);
	nonOwnedID.addAttribute(key, nonOwnedAttribute);
        nonOwnedID.addCertificate(key, cert2);
        assertFalse(nonOwnedID.getAttribute(key).getCertificate(newOwner) == cert2);
    }

    function testChangeOwner(){
        ownedID.changeOwner(newOwner);
        assertEq(newOwner, ownedID.owner());
    }

    function testCreateCertificate(){
        Certificate newCert = ownedID.createCertificate("created certificate", "2323", ownedAttribute);
        //Making sure the new cert belongs to the ID that created it
        assertEq(newCert.owner(), ownedID);
    }

    function testRevokeCertificate(){
        //Creating new cert and revoking it
        Certificate newCert = ownedID.createCertificate("created certificate", "2323", ownedAttribute);
        assertFalse(cert.revoked());
        ownedID.revokeCertificate(cert);
        assertTrue(cert.revoked());
    }
}
//Dummy contract to set as new owner.
contract DummyOwner{
    ID id;

    function createDummyCertificate(Attribute ownedAttribute) returns (Certificate){
        return new Certificate("test cert 2", "1234", ownedAttribute);
    }

    function createID() returns (ID){
        id = new ID();
        return id;
    }

    function addAttribute(bytes32 key, Attribute ownedAttribute){
        id.addAttribute(key, ownedAttribute);
    }
}

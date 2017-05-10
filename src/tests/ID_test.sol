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
    ID notOwnedID;
    Attribute attr;
    Attribute attr2;
    Certificate cert;
    DummyOwner newOwner;
    bytes32 key;
    
    function setUp() {
        newOwner = new DummyOwner();
        ownedID = new ID();
        notOwnedID = newOwner.createID();
        attr = new Attribute("test attr", "5678", ownedID);
        attr2 = new Attribute("test attr", "5678", notOwnedID);
        cert = new Certificate("test cert", "1234", attr);
        key = sha3("hello");

    }

    //operations that should not be possible unless you own the ID
    function testNotOwnerAddAttribute(){
        notOwnedID.addAttribute(key, attr);
        assertFalse(notOwnedID.getAttribute(key) == attr);
    }

    function testNotOwnerRemoveAttribute(){
        newOwner.addAttribute(key, attr2);
        notOwnedID.removeAttribute(key);
        assertEq(notOwnedID.getAttribute(key), attr2);
    }

    function testNotOwnerChangeOwner(){
        notOwnedID.changeOwner(this);
        assertFalse(notOwnedID.owner() == address(this));
    }

    function testAddAndGetAttribute(){
        
        //Adding attribute to ID        
        ownedID.addAttribute(key, attr);
        assertEq(ownedID.getAttribute(key), attr);
        //Make sure ID is the owner of the attribute
        assertEq(ownedID.getAttribute(key).owner(), address(ownedID));
    }

    function testThrowAddAttribute(){
        //Adding an attribute with the wrong owner should result in a failure
        ownedID.addAttribute(key, attr2);
    }

    function testAddAndRemoveAttribute(){
        //Adding attribute to ID, again      
        ownedID.addAttribute(key, attr);
        assertEq(ownedID.getAttribute(key), attr);
        //Removing attribute from ID - should not be equal any more
        ownedID.removeAttribute(key);
        assertFalse(ownedID.getAttribute(key) == attr);
    }

    function testAddCertificateByKey(){
        //Adding attribute and cert to attribute by key
        ownedID.addAttribute(key, attr);
        ownedID.addCertificate(key, cert);
        //Getting the certificate issued by this contract
        Certificate testedCert = ownedID.getAttribute(key)
                                    .getCertificate(this);
        assertEq(testedCert, cert);
        //Test adding certificate without being owner
        ownedID.changeOwner(newOwner);
        Certificate cert2 = newOwner.createDummyCertificate(attr);
        ownedID.addCertificate(key, cert2);
        assertEq(ownedID.getAttribute(key).getCertificate(newOwner), cert2);

    }

    function testAddCertificateByAttribute(){
        //Adding attribute and cert to attribute by key
        ownedID.addAttribute(key, attr);
        ownedID.addCertificate(attr, cert);
        //Getting the certificate issued by this contract
        Certificate testedCert = ownedID.getAttribute(key)
                                    .getCertificate(this);
        assertEq(testedCert, cert);    
        //Test adding certificate without being owner
        ownedID.changeOwner(newOwner);
        Certificate cert2 = newOwner.createDummyCertificate(attr);
        ownedID.addCertificate(attr, cert2);
        assertEq(ownedID.getAttribute(key).getCertificate(newOwner), cert2);

    }

    function testChangeOwner(){
        ownedID.changeOwner(newOwner);
        assertEq(newOwner, ownedID.owner());
    }

    function testCreateCertificate(){
        //Creating attribute and cert for that attribute
        ownedID.addAttribute(key, attr);
        Certificate newCert = ownedID.createCertificate("created certificate", "2323", attr);
        //Making sure the new cert belongs to the ID that created it
        assertEq(newCert.owner(), ownedID);
    }
}
//Dummy contract to set as new owner.
contract DummyOwner{
    ID id;

    function createDummyCertificate(Attribute attr) returns (Certificate){
        return new Certificate("test cert 2", "1234", attr);
    }

    function createID() returns (ID){
        id = new ID();
        return id;
    }

    function addAttribute(bytes32 key, Attribute attr){
        id.addAttribute(key, attr);
    }
}

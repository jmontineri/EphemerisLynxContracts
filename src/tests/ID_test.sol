pragma solidity ^0.4.7;
import "dapple/test.sol"; // virtual "dapple" package imported when `dapple test` is run
import "mortal.sol";
import "Attribute.sol";
import "Certificate.sol";
import "Factory.sol";
import "ID.sol";
import "IDController.sol";

contract IDTest is Test{
    ID id1;
    Attribute attr;
    Certificate cert;
    DummyOwner newOwner;
    bytes32 key;
    
    function setUp() {
        id1 = new ID();
        attr = new Attribute("test attr", "5678", this);
        cert = new Certificate("test cert", "1234", attr);
        newOwner = new DummyOwner();
        key = sha3("hello");
    }
    
    function testAddAndGetAttribute(){
        
        //Adding attribute to ID        
        id1.addAttribute(key, attr);
        assertEq(id1.getAttribute(key), attr);
        //Make sure ID is the owner of the attribute
        assertEq(id1.getAttribute(key).owner(), address(id1));
    }

    function testAddAndRemoveAttribute(){
        //Adding attribute to ID, again      
        id1.addAttribute(key, attr);
        assertEq(id1.getAttribute(key), attr);
        //Removing attribute from ID - should not be equal any more
        id1.removeAttribute(key);
        assertFalse(id1.getAttribute(key) == attr);
    }

    function testAddCertificateByKey(){
        //Adding attribute and cert to attribute by key
        id1.addAttribute(key, attr);
        id1.addCertificate(key, cert);
        //Getting the certificate issued by this contract
        Certificate testedCert = id1.getAttribute(key)
                                    .getCertificate(this);
        assertEq(testedCert, cert);
    }

    function testAddCertificateByAttribute(){
        //Adding attribute and cert to attribute by key
        id1.addAttribute(key, attr);
        id1.addCertificate(attr, cert);
        //Getting the certificate issued by this contract
        Certificate testedCert = id1.getAttribute(key)
                                    .getCertificate(this);
        assertEq(testedCert, cert);    
    }

    function testChangeOwner(){
        id1.changeOwner(newOwner);
        assertEq(newOwner, id.owner);
    }

    function testCreateCertificate{
        //Creating attribute and cert for that attribute
        id1.addAttribute(key, attr);
        Certificate newCert = id1.createCertificate("created certificate", "2323", attr);
        //Making sure the new cert belongs to the ID that created it
        assertEq(new.owner, id1);
    }
}
//Dummy contract to set as new owner.
contract DummyOwner{
}
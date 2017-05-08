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
    
    function setUp() {
        id1 = new ID();
        attr = new Attribute("test attr", "5678", this);
        cert = new Certificate("test cert", "1234", attr);
        newOwner = new DummyOwner();
    }
    
    function testAddAndGetAttribute(){
        
        //Adding attribute to ID        
        id1.addAttribute("hello", attr);
        assertEq(id1.getAttribute("hello"), attr);
        //Make sure ID is the owner of the attribute
        assertEq(id1.getAttribute("hello").owner(), address(id1));
    }

    function testAddAndRemoveAttribute(){
        //Adding attribute to ID, again      
        id1.addAttribute("hello", attr);
        assertEq(id1.getAttribute("hello"), attr);
        //Removing attribute from ID - should not be equal any more
        id1.removeAttribute("hello");
        assertFalse(id1.getAttribute("hello") == attr);
    }

    function testAddCertificateByKey(){
        //Adding attribute and cert to attribute by key
        id1.addAttribute("hello", attr);
        id1.addCertificate("hello", cert);
        //Getting the certificate issued by this contract
        Certificate testedCert = id1.getAttribute("hello")
                                    .getCertificate(this);
        assertEq(testedCert, cert);
    }

    function testAddCertificateByAttribute(){
        //Adding attribute and cert to attribute by key
        id1.addAttribute("hello", attr);
        id1.addCertificate(attr, cert);
        //Getting the certificate issued by this contract
        Certificate testedCert = id1.getAttribute("hello")
                                    .getCertificate(this);
        assertEq(testedCert, cert);    
    }

    function testChangeOwner(){
        id1.changeOwner(newOwner);
        assertEq(newOwner, id.owner);
    }

    function testCreateCertificate{
        //Creating attribute and cert for that attribute
        id1.addAttribute("hello", attr);
        Certificate newCert = id1.createCertificate("created certificate", "2323", attr);
        //Making sure the new cert belongs to the ID that created it
        assertEq(new.owner, id1);
    }
}
//Dummy contract to set as new owner.
contract DummyOwner{
}
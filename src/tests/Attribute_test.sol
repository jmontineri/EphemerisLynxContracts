pragma solidity ^0.4.7;
import "dapple/test.sol"; // virtual "dapple" package imported when `dapple test` is run
import "Certificate.sol";

contract AttributeTest is Test {
    Certificate cert;
    Attribute attr;
    AttributeTestProxy attrProxy;

    function setUp(){
        attrProxy = new AttributeTestProxy();
        attr = new Attribute("hogwarts", "description", "1234", attrProxy);
        attrProxy.setAttr(attr);
        cert = attrProxy.createCertificate();
    }

    function testAddAndGetCertificate(){

        log_address(cert.owner());
        assertEq(attr.certificateCount(), 0);

        //add the certificate not as the owner of the attribute
        attr.addCertificate(cert);
        assertFalse(attr.getCertificate(this) == cert);


        //add the certificate as the owner of the attribute
        attrProxy.addCertificate(cert);
        assertEq(attr.getCertificate(attrProxy), cert);

        assertEq(attr.certificateCount(), 1);
        log_address(attr.certificateKeys(0));
    }
}

//This proxy contract will act as a second actor calling the watchdog contract
contract AttributeTestProxy{
    Attribute public attr;
    Certificate public cert;

    function createCertificate() returns (Certificate){
        //The certificate needs to be owned by the message sender so that the
        //contract accepts it
        if(address(attr) == 0)
            throw;

        return cert = new Certificate("over the rainbow", "5678", attr);
    }

    function setAttr(Attribute _attr){
        attr = _attr;
    }

    function addCertificate(Certificate _cert){
        attr.addCertificate(_cert);
    }
}

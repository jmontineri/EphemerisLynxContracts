pragma solidity ^0.4.7;
import "dapple/test.sol"; // virtual "dapple" package imported when `dapple test` is run
import "Attribute.sol";
import "Certificate.sol";

contract CertificateTest is Test {
    CertificateTestProxy certProxy;
    Attribute attr;
    Certificate cert;
    
    function setUp() {
        attr = new Attribute("neverland", "5678", address(this));
        certProxy = new CertificateTestProxy(attr);
        cert = certProxy.cert();
    }
    
    function testRevoke(){
        //test initial state
        assertFalse(cert.revoked());
        
        //revoke directly from this contract should fail
        cert.revoke();
        assertFalse(cert.revoked());
        
        //revoking from the proxy should work
        certProxy.revoke();
        assertTrue(cert.revoked());
    }
}

//This proxy contract will act as a second actor calling the watchdog contract
contract CertificateTestProxy{
    Certificate public cert;
    
    function CertificateTestProxy(Attribute attr){
        cert = new Certificate("somewhere", "1234", attr);
    }
    
    function revoke(){
        cert.revoke();
    }
}
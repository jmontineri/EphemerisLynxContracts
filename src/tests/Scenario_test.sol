pragma solidity ^0.4.7;
import "dapple/test.sol"; // virtual "dapple" package imported when `dapple test` is run
import "mortal.sol";
import "Attribute.sol";
import "Certificate.sol";
import "Factory.sol";
import "ID.sol";
import "IDController.sol";

contract ScenarioTest is Test {
    Factory factory;
    IDController idCtrl1;
    ID id1;
    IDController idCtrl2;
    ID id2;
    Attribute attr1;
    Attribute attr2;
    Certificate cert1;
    Certificate cert2;

    function setUp() {
        factory = new Factory();
    }

    function testRun(){
        createIdOne();

        createIdTwo();

        addAttributeToIdOne();

        addAttributeToIdTwo();

        issueCertificateForAttr1();

        issueCertificateForAttr2();

        removeAttribute2();

        revokeCertificate2();
    }

    function createIdOne(){
        //create the ID, get the returned IDController
        idCtrl1 = factory.createID();
        //Get the actual ID from the controller
        id1 = idCtrl1.getID();

        //ensure that current contract is the owner of the controller
        assertEq(this, address(idCtrl1.owner()));

        //ensure that the controller contract is the owner of the id
        assertEq(address(idCtrl1), address(id1.owner()));

        log_named_string("status", "ID 1 created");
    }

    function createIdTwo(){
        //create the ID, get the returned IDController
        idCtrl2 = factory.createID();
        //Get the actual ID from the controller
        id2 = idCtrl2.getID();

        //ensure that current contract is the owner of the controller
        assertEq(this, address(idCtrl2.owner()));

        //ensure that the controller contract is the owner of the id
        assertEq(address(idCtrl2), address(id2.owner()));

        log_named_string("status", "ID 2 created");
    }

    function addAttributeToIdOne(){
        //create the attribute
         attr1 = new Attribute("location1", "attr1", "hash1", address(id1));

        //add the attribute to the ID
        idCtrl1.addAttribute(attr1);

        assertEq(address(id1.getAttribute("attr1")), address(attr1));

        log_named_string("status", "Attr1 added to ID1");
    }

    function addAttributeToIdTwo(){
        //create the attribute
         attr2 = new Attribute("location2", "attr2", "hash2", address(id2));

        //add the attribute to the ID
        idCtrl2.addAttribute(attr2);

        assertEq(address(id2.getAttribute("attr2")), address(attr2));

        log_named_string("status", "Attr2 added to ID2");
    }

    function issueCertificateForAttr1(){
        //Get the attribute name attr1 from ID1 and create a certificate for it
         cert1 = idCtrl2.createCertificate("cert1Location", "cert1Hash", id1.getAttribute("attr1"));

        log_named_string("status", "Certificate cert1 was created for attr1 by ID2");

        //add the certificate to the attribute
        idCtrl1.addCertificate(attr1, cert1);

        assertEq(cert1, attr1.getCertificate(address(id2)));

        log_named_string("status", "Certificate cert1 was added to attr1 of ID1");
    }

    function issueCertificateForAttr2(){
        //Get the attribute name attr2 from ID2 and create a certificate for it
         cert2 = idCtrl1.createCertificate("cert2Location", "cert2Hash", id2.getAttribute("attr2"));

        log_named_string("status", "Certificate cert2 was created for attr2 by ID1");

        //add the certificate to the attribute
        idCtrl2.addCertificate(attr2, cert2);

        assertEq(cert2, attr2.getCertificate(address(id1)));

        log_named_string("status", "Certificate cert2 was added to attr2 of ID2");
    }

    function removeAttribute2(){
        //make sure the attribute still exists in the ID
        assertEq(attr2, idCtrl2.getAttribute("attr2"));

        //ID1 revoke certificate 2 issued for attribute 2 of ID2
        idCtrl2.removeAttribute("attr2");

        //make sure the attribute was removed
        assertEq("0x0000000000000000000000000000000000000000", idCtrl2.getAttribute("attr2"));

        log_named_string("status", "attr2 of ID2 was deleted by ID2");
    }


    function revokeCertificate2(){
        //ID1 revoke certificate 2 issued for attribute 2 of ID2
        idCtrl1.revokeCertificate(cert2);

        assertTrue(cert2.revoked());

        log_named_string("status", "ID1 revoked cert2 issued for attr2 of ID2");
    }




    ///////////////////
    //utility functions
    ///////////////////
    function bytes32ToString(bytes32 x) constant returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    function bytes32ArrayToString(bytes32[] data) returns (string) {
        bytes memory bytesString = new bytes(data.length * 32);
        uint urlLength;
        for (uint i=0; i<data.length; i++) {
            for (uint j=0; j<32; j++) {
                byte char = byte(bytes32(uint(data[i]) * 2 ** (8 * j)));
                if (char != 0) {
                    bytesString[urlLength] = char;
                    urlLength += 1;
                }
            }
        }
        bytes memory bytesStringTrimmed = new bytes(urlLength);
        for (i=0; i<urlLength; i++) {
            bytesStringTrimmed[i] = bytesString[i];
        }
        return string(bytesStringTrimmed);
    }

    function stringToBytes32(string memory source) returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }
}

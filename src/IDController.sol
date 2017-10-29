pragma solidity ^ 0.4 .7;
import "Owned.sol";
import "ID.sol";
import "Watchdog.sol";
import "Attribute.sol";
import "Registry.sol";

contract IDController is Owned {
    ID id;
    Registry registry;
    Watchdog watchdogs;

    function IDController(ID _id) {
        id = _id;
    }

    function changeRegistry (Registry newRegistry) onlyowner{
        registry = newRegistry;
    }

    function removeAttribute(bytes32 key) onlyowner {
       id.removeAttribute(key);
    }

    //function removeAllAttributes()

    function addAttribute(Attribute attr) onlyowner returns(bool) {
        return id.addAttribute(attr);
    }

    function getAttribute(bytes32 key) constant returns(Attribute) {
        return id.getAttribute(key);
    }

    function attributeCount() constant returns(uint256) {
        return id.attributeCount();
    }

    function getAttributeKey(uint256 i) returns (bytes32){
        return id.attributesKeys(i);
    }

    function deleteID() onlyowner {
        id.kill();
        selfdestruct(owner);
    }

    function getWatchDogs() constant returns (Watchdog){
        return watchdogs;
    }

    function getID() constant returns (ID){
        return id;
    }

    function createCertificate(string _location, string _hash, Attribute _owningAttribute) onlyowner returns (Certificate) {
        return id.createCertificate(_location, _hash, _owningAttribute);
    }

    function addCertificate(bytes32 key, Certificate cert) onlyowner{
        id.addCertificate(key, cert);
    }

    function addCertificate(Attribute attr, Certificate cert) onlyowner{
        id.addCertificate(attr, cert);
    }

    function revokeCertificate(Certificate cert){
        id.revokeCertificate(cert);
    }

    function setWatchDogs(Watchdog newContract) onlyowner {
        watchdogs = newContract;
    }

    function takeOwnership() onlyowner{
        registry.setAddress(id);
    }

    function changeOwner(address newOwner) onlyowner {
        owner = newOwner;
    }

    modifier onlyowner() {
        if (msg.sender == owner || msg.sender == address(watchdogs)) _;
    }
}

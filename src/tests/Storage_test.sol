pragma solidity ^0.4.7;
import "dapple/test.sol"; // virtual "dapple" package imported when `dapple test` is run
import "Storage.sol";

contract StorageTest is Test{
    
    Storage userStorage;
    bytes32 key1;
    bytes32 key2;
    Dummy dummy1;
    Dummy dummy2;

    function setUp() {
        userStorage = new Storage();
        key1 = "key 1";
        key2 = "key 2";
        dummy1 = new Dummy();
        dummy2 = new Dummy();
    }

    function testAdd() {
        userStorage.add(key1, dummy1);
        userStorage.add(key2, dummy2);
        assertEq(userStorage.length(), 2);
    }

    function testAddAndGetByKey(){
        testAdd();

        assertEq(userStorage.getByKey(key1), dummy1);
        assertEq(userStorage.getByKey(key2), dummy2);
    }

    function testAddAndGetByIndex(){
        testAdd();

        assertEq(userStorage.getByIndex(0), dummy1);
        assertEq(userStorage.getByIndex(1), dummy2);
    }

    function testRemove(){
        testAdd();
        userStorage.remove(key1);

        assertEq(userStorage.getByIndex(0), dummy2);
        assertEq(userStorage.getByKey(key1), 0x0);
        assertEq(userStorage.getByIndex(1), 0x0);

        userStorage.remove(key2);

        assertEq(userStorage.length(), 0);
        assertEq(userStorage.getByIndex(0), 0x0);
    }
}

    contract Dummy{
    }

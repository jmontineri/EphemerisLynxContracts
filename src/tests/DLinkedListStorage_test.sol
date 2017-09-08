pragma solidity ^0.4.7;
import "dapple/test.sol"; // virtual "dapple" package imported when `dapple test` is run
import "DLinkedListStorage.sol";

contract StorageTest is Test{
    
    DLinkedListStorage userStorage;
    bytes32 key1;
    bytes32 key2;
    Dummy dummy1;
    Dummy dummy2;

    function setUp() {
        userStorage = new DLinkedListStorage();
        key1 = "key 1";
        key2 = "key 2";
        dummy1 = new Dummy();
        dummy2 = new Dummy();
    }

    function testAdd() {
        assertEq(userStorage.item_count(), 0);

        userStorage.add(key1, dummy1);
        userStorage.add(key2, dummy2);

        assertEq(userStorage.item_count(), 2);
    }

    function testUpdate(){
        assertEq(userStorage.item_count(), 0);

        userStorage.add(key1, dummy1);

        assertEq(userStorage.getByKey(key1), dummy1);
        assertEq(userStorage.item_count(), 1);

        userStorage.add(key1, dummy2);

        assertEq(userStorage.item_count(), 1);
        assertEq(userStorage.getByKey(key1), dummy2);
        
    }

    function testAddAndGetByKey(){
        testAdd();

        assertEq(userStorage.getByKey(key1), dummy1);
        assertEq(userStorage.getByKey(key2), dummy2);
    }


    //Unit testing getAll() is impossible from Solidity

    function testRemove(){
        testAdd();
        
        assertEq(userStorage.item_count(), 2);
        assertEq(userStorage.getByKey(key1), dummy1);

        userStorage.remove(key1);

        assertEq(userStorage.item_count(), 1);
        assertEq(userStorage.getByKey(key1), 0x0);
        assertEq(userStorage.getByKey(key2), dummy2);

        userStorage.remove(key2);

        assertEq(userStorage.item_count(), 0);
        assertEq(userStorage.getByKey(key2), 0x0);
    }
}

    contract Dummy{
    }

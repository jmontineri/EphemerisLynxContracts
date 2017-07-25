pragma solidity ^0.4.7;
import "Owned.sol";

contract Storage is Owned{
    
    struct Node{
        bytes32 previous;
        bytes32 next;
        address pointer;
    }

    mapping(bytes32 => Node) nodes;

    Node head = Node("", "LIST_TAIL", 0x0);
    Node tail = Node("LIST_HEAD", "", 0x0);

    modifier no_dummy_keys (bytes32 key){
        if(key == "LIST_HEAD" || key == "LIST_TAIL")
            throw;
        _;
    }

    function Storage(){
        nodes["LIST_HEAD"] = head;
        nodes["LIST_TAIL"] = tail;
    }

    function add(bytes32 key, address value) onlyowner no_dummy_keys(key){
        nodes[key] = Node(tail.previous, "LIST_TAIL", value);
        nodes[tail.previous].next = key;
        tail.previous = key;
    }

    function remove(bytes32 key) onlyowner no_dummy_keys(key){
        Node toRemove = nodes[key];
        if(toRemove.pointer == 0x0)
            throw;
        nodes[toRemove.next].previous = toRemove.previous;
        nodes[toRemove.previous].next = toRemove.next;
        delete nodes[key];
    }

    function get(bytes32 key) constant returns(address){
        return nodes[key].pointer;
    }

    function get(int index) constant returns(address){
        Node current = head;

        for(int i = 0; i < index; i++){
            current = nodes[current.next];
        }

        return current.pointer;
    }

    function length() constant returns(int){
        int count = 0;

        for(bytes32 current = "LIST_HEAD"; current != "LIST_TAIL"; current = nodes[current].next){
            count++;
        }

        return count;
    }


}

pragma solidity ^0.4.7;
import "Owned.sol";

contract DLinkedListStorage is Owned{
    
    struct Node{
        bytes32 previous;
        bytes32 next;
        address pointer;
    }

    mapping(bytes32 => Node) nodes;

    Node head = Node("", "LIST_TAIL", 0x0);
    Node tail = Node("LIST_HEAD", "", 0x0);

    uint256 public item_count;

    // Ensure that the key passed to the function is neither a dummy key nor a null key
    modifier no_dummy_keys (bytes32 key){
        if(key == "LIST_HEAD" || key == "LIST_TAIL" || key == 0x0)
            throw;
        _;
    }

    function Storage(){
        nodes["LIST_HEAD"] = head;
        nodes["LIST_TAIL"] = tail;
    }

    // Add a value to the LinkedList. If the key exists already, the value is updated.
    function add(bytes32 key, address value) onlyowner no_dummy_keys(key){
        Node existing_node = nodes[key];
        //Check if the node does not exists
        if(existing_node.next == 0x0){
            nodes[key] = Node(tail.previous, "LIST_TAIL", value);
            nodes[tail.previous].next = key;
            tail.previous = key;
            item_count++;
        }
        else{
            existing_node.pointer = value;
        }
    }

    // Removes a value from the LinkedList, if it exists
    function remove(bytes32 key) onlyowner no_dummy_keys(key){
        Node to_remove = nodes[key];
        if(to_remove.next == 0x0)
            throw;

        nodes[to_remove.next].previous = to_remove.previous;
        nodes[to_remove.previous].next = to_remove.next;
        delete nodes[key];
        item_count--;
    }

    // Get an element by its key
    function getByKey(bytes32 key) constant returns(address){
        return nodes[key].pointer;
    }

    // Get an array of all elements in the list
    function getAll() constant returns(address[]){
        address[] memory ret = new address[](item_count);
        uint256 item = 0;

        for(bytes32 current = nodes["LIST_HEAD"].next; current != "LIST_TAIL"; current = nodes[current].next){
            ret[item] = nodes[current].pointer;
            item++;
        }

        return ret;
    }
}

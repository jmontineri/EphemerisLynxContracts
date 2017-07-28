library LibStorage{

    struct Node{
        bytes32 previous;
        bytes32 next;
        address pointer;
    }

    struct LinkedList{
        mapping(bytes32 => Node) nodes;

        Node head = Node("", "LIST_TAIL", 0x0);
        Node tail = Node("LIST_HEAD", "", 0x0);
    }


    modifier no_dummy_keys (bytes32 key){
        if(key == "LIST_HEAD" || key == "LIST_TAIL")
            throw;
        _;
    }
    function add(LinkedList list, bytes32 key, address value) onlyowner no_dummy_keys(key){
        list.nodes[key] = Node(list.tail.previous, "LIST_TAIL", value);
        list.nodes[list.tail.previous].next = key;
        list.tail.previous = key;
    }

    function remove(LinkedList list, bytes32 key) onlyowner no_dummy_keys(key){
        Node toRemove = list.nodes[key];
        if(toRemove.pointer == 0x0)
            throw;
        list.nodes[toRemove.next].previous = toRemove.previous;
        list.nodes[toRemove.previous].next = toRemove.next;
        delete list.nodes[key];
    }

    function getByKey(LinkedList list, bytes32 key) constant returns(address){
        return list.nodes[key].pointer;
    }

    function getByIndex(LinkedList list, int index) constant returns(address){
        bytes32 current = "LIST_HEAD";

        for(int i = 0; i <= index; i++){
            current = list.nodes[current].next;
        }

        return list.nodes[current].pointer;
    }

    function length(LinkedList list) constant returns(int){
        int count = 0;

        for(bytes32 current = nodes["LIST_HEAD"].next; current != "LIST_TAIL"; current = nodes[current].next){
            count++;
        }

        return count;
    }
}

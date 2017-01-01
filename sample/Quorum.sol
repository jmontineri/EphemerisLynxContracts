contract Quorum is mortal{
    
    function hasQuorum() returns (bool){
        if(msg.sender == owner)
            return true;
        else
            return false;
    }
}
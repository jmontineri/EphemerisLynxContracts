contract('Watchdog', function(accounts) {
  
  it("test propose() function", function(done) {
      var watchdog = Watchdog.deployed();
      var idCtrl = IDController.deployed();
      
      //First add a second owner
      watchdog.addMultisigOwner(accounts[1])
      .then(function(tx){
        //Then issue a proposal
        
      });
      
      done();
  });
  
});
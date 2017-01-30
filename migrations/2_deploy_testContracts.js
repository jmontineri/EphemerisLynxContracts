module.exports = function(deployer) {
  deployer.deploy(owned);
  deployer.deploy(mortal);
  deployer.deploy(Factory);
  deployer.deploy(Attribute);

  deployer.deploy(ID).then(function() {
    
    //deploy the controller
    return deployer.deploy(IDController, ID.address)
    
    .then(function() {
      
      //deploy the watchgod contract
      return deployer.deploy(Watchdog, [], 1)
      
      .then(function() {
        
        //add the watchdog contact to the IDController contract
        var idCtrl = IDController.deployed();
        idCtrl.setWatchDogs(Watchdog.address);
        
      });
    });
  });
  
};

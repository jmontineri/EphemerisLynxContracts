contract('FactoryTest', function(accounts) {
  it("createID() should return a contract of type IDController", function(done) {
    var factory = Factory.deployed();

    return factory.createID().then(function(tx){

      //Watch for the event with created by the transaction we just made
      var returnIDControllerEvent = factory.ReturnIDController({transactionHash: tx});
      return returnIDControllerEvent;

    }).then(function(event){
      //////////////
      // Make sure we can call function that belongs to IDController interface
      /////////////

      //start watching
      return event.watch(function(error, result){

        if (error == null) {
          //get the IDController contract
          var idController = IDController.at(result.args._controllerAddress);
          console.log("!!!!!!! "+result.args._controllerAddress);
          //Test if we can if the Contract type is indeed IDController
          //by calling a function on the contract and see if it succeeds
          return idController.getAttribute.call("testKey").then(function(){
            assert.isTrue(true);
          }).catch(function(e){
            console.log(e);
            assert.isTrue(false);
          });
        } else {
          //if there is an error, fail the test
          assert.isTrue(false);
        }
      });
    }).then(function(event){

      //////////////
      // Make sure we can't call function that don't belong to IDController interface
      /////////////

      //start watching
      event.watch(function(error, result){
        if (error == null) {
          //Try to instantiate as the IDController contract as an Attribute contract
          var fakeAttribute = Attribute.at(result.args._controllerAddress);

          //Test if we can if the Contract type is indeed IDController
          //by calling a function on the contract and see if it succeeds
          return fakeAttribute.getLocation.call().then(function(){
            //if we can call the function, then the test should fail
            assert.isTrue(false);
            event.stopWatching();
            done();
          }).catch(function(e){
            //if we can't call the function then the test pass
            assert.isTrue(true);
            event.stopWatching();
            done();
          });
        } else {
          //if there is an error, fail the test
          assert.isTrue(false);
          event.stopWatching();
          done();
        }
      });
    });
  });
});

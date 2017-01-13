contract('Attribute', function(accounts) {
  var location = "localhost";
  it("Set  the location string, and get ", function(done) {
    var attribute = Attribute.deployed();
    
    //set the location
    attribute.setLocation(location).then(function(tx){
      //get the location
      attribute.getLocation.call().then(function(setLoc){
        assert.equal(setLoc, location);
        done();
      });
    });
  });
});

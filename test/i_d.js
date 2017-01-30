/*contract('ID', function(accounts) {
  it("should create new attribute", function(done) {
    var i_d = ID.deployed();
    var newAttribute = "testAttr";
    var newAttrLocation = "www.testurl.com";
    // var finalattrLocation;
    // var finalAttrName;
    //add new attribute
    return i_d.addAttribute(newAttribute, newAttrLocation).then(function() {
      //retrieve attribute location
      return i_d.getAttribute.call(newAttribute).then(function(attribute) {
        console.log(attribute);
        var attr = Attribute.at(attribute);
        console.log(attr);
        attr.getLocation.call().then(function(finalattrLocation) {
          console.log("getLocation Transaction Success");
          //compare attributeLocation value with expected value
          console.log(finalattrLocation);
          assert.equal(newAttrLocation, finalattrLocation, "FAIL");
          done();
        }).catch(function(e) {
          console.log(e);
        });
      });
    });
  });

  it("should remove attribute", function(done) {
    var i_d = ID.deployed();
    var attr = "Name";
    var removedAttrLoc;

    return i_d.addAttribute(attr, "www.deleteme.com").then(function() {

      return i_d.removeAttribute(attr).then(function() {

        return i_d.getAttribute.call(attr).then(function(attribute) {
          assert.equal(attribute, "0x0000000000000000000000000000000000000000", "FAIL2");
          done();
        });
      });
    });

  });

  it("should remove all attributes", function(done) {
    var i_d = ID.deployed();
    var attr1 = "First Name";
    var attr2 = "Last Name";
    var loc1 = "link1";
    var loc2 = "link2";

    return i_d.addAttribute(attr1, loc1).then(function() {
      i_d.addAttribute(attr2, loc2).then(function() {
        i_d.removeAllAttributes().then(function() {
          i_d.getAttribute.call(attr2).then(function(attribute) {
              assert.equal(attribute,  "0x0000000000000000000000000000000000000000", "FAIL");
                return i_d.getAttribute.call(attr1).then(function(attribute2) {
                assert.equal(attribute2,  "0x0000000000000000000000000000000000000000", "FAIL");
                done();
              });
          });
        });
      });
    });







  });




});
*/
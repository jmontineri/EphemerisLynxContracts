module.exports = function(deployer) {
  deployer.deploy(owned);
  deployer.deploy(mortal);
  deployer.deploy(Factory);
  deployer.deploy(ID);
  deployer.deploy(Attribute);
  deployer.deploy(IDController);
};

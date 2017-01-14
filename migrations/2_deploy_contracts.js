module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.autolink();
  deployer.deploy(owned);
  deployer.deploy(mortal);
  deployer.deploy(Factory);
  deployer.deploy(ID);
  deployer.deploy(Attribute);
  deployer.deploy(IDController);
};

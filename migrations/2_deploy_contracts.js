const Hotel = artifacts.require("Hotel");

module.exports = async function (deployer) {
  const accounts = await web3.eth.getAccounts();
  console.log("Attempting to deploy from" + accounts[0]);
  const hotel = await deployer.deploy(Hotel);
};

const Hotel = artifacts.require("Hotel");
const HotelFactory = artifacts.require("HotelFactory");
const Token = artifacts.require("Token");

module.exports = async function (deployer) {
  const accounts = await web3.eth.getAccounts();
  console.log("Attempting to deploy from" + accounts[0]);
  deployer.deploy(Hotel);
  //deployer.deploy(HotelFactory); NOT DEPLOYING artifact/network mismatch
  //deployer.deploy(Token);
};

// const mint = artifacts.require("mint");
const Mint = artifacts.require("Mint");
const Migrations = artifacts.require("Migrations");
const N2DRewards = artifacts.require("N2DRewards");
const test = artifacts.require("test");
// const KlaytnGreeter = artifacts.require("KlaytnGreeter");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  // deployer.deploy(Mint);  
  // deployer.deploy(N2DRewards);
  deployer.deploy(test, '0x58D8ECe142c60f5707594a7C1D90e46eAE5AF431', '0x24C5097A0fD5EC3b8A8d4f269Fd6490355902831', '0x837D63C36B674b688ee74A31DABCc3490821C3B6');
  // deployer.deploy(KlaytnGreeter, "Hello Klaytn");
};

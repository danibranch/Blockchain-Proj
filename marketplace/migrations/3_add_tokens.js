var Token = artifacts.require("./Token.sol")

module.exports = async function(deployer) {
    const instance = await Token.deployed()
    return await instance.approve.sendTransaction("0x9bCdE8d23dEAa080554cd0f60E60DaC2E48cb147", 1000, {from: "0x41e560F80c262D18dc5577623B0fE2Db736b778C"})
}
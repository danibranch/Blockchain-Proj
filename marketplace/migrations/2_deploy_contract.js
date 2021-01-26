var Token = artifacts.require("./Token.sol")
var Marketplace = artifacts.require("./Marketplace.sol")

module.exports = function(deployer) {
    deployer.deploy(Token, {from: "0x41e560F80c262D18dc5577623B0fE2Db736b778C"}).then(() => {
        return deployer.deploy(Marketplace, Token.address, {from: "0x41e560F80c262D18dc5577623B0fE2Db736b778C"})
    })
}
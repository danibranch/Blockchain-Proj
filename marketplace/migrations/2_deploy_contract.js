var Token = artifacts.require("./Token.sol")
var Marketplace = artifacts.require("./Marketplace.sol")

module.exports = function(deployer) {
    deployer.deploy(Token).then(() => {
        return deployer.deploy(Marketplace, Token.address)
    })
}
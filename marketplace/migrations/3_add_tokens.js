var Token = artifacts.require("./Token.sol")
var marketplace = artifacts.require("./Marketplace.sol")

module.exports = async function(deployer) {
    const tokenInstance = await Token.deployed()
    const marketplaceInstance = await marketplace.deployed()
    return await tokenInstance.approve.sendTransaction(marketplaceInstance.address, 1000)
}
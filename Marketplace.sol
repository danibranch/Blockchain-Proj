pragma solidity ^0.6.2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.3.0/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {

    constructor () public ERC20("Token", "TKN") {
        _mint(msg.sender, 1000000 * (10 ** uint256(decimals())));
    }
}


contract Marketplace {
    Token tokenContract;
    address owner;
    // uint8 prodID;
    uint prodTotal; //id
    uint activeProd;
    
    
    struct Manager {
        string name;
        uint reputation;
    }

    struct Freelancer {
        string name;
        uint reputation;
        string expertiseDomain;
    }

    struct Evaluator {
        string name;
        uint reputation;
        string expertiseDomain;
    }
    
    struct Financier {
        string name;
    }

    struct Product {
        uint id;
        bool active;
        string description;
        uint developingCost;
        uint evaluatorCompensation;
        uint balance;
        uint totalSum;
        string expertiseDomain;
        address associatedManager;
        mapping(address => uint) finantare;
    }

    mapping(address => Manager) public managerList;
    mapping(address => Freelancer) public freelencerList;
    mapping(address => Evaluator) public evaluatorList;
    mapping(address => Financier) public financierList;
    mapping(uint => Product) public productList;
    
    mapping(address => Product[]) public managerToProduct;

    modifier onlyManager(){
        require(bytes(managerList[msg.sender].name).length != 0, "mesaj");
        _;
    }
    
    modifier onlyFinancier(){
        require(bytes(financierList[msg.sender].name).length != 0, "mesaj");
        _;
    }

    event newFinantare(
        address from,
        uint contribution
        );
        
        //finantare(produs, finantator)-> 

    event productGoalReached();
    

    //functions for init manager, freelancer, evaluator, sponsor
    function initManager(string memory _name) public returns (bool success){
        managerList[msg.sender] = Manager(_name, 5);
        return true;
    }
    
    function addProduct(string calldata prodDescription, uint developCost, uint evalCompensation, string calldata domainProd) external onlyManager() {
        uint totalSumProd = developCost + evalCompensation;
        // managerToProduct[msg.sender].finantare.financierAdd = "";
        // managerToProduct[msg.sender].finantare.amountFinanced = 0;

        managerToProduct[msg.sender].push(Product(prodTotal, true, prodDescription, developCost, evalCompensation, 0, totalSumProd, domainProd, msg.sender));
        prodTotal += 1;
    }
    
    // only to be called by managers
    function inactivateProduct(uint id) public onlyManager() {
        productList[id].active = false;
        //
    }
    
    function initFreelancer(string memory _name, string memory _expertiseDomain) public returns (bool success){
        freelencerList[msg.sender] = Freelancer(_name, 5, _expertiseDomain);
        return true;
    }
    
    function initEvaluator(string memory _name, string memory _expertiseDomain) public returns (bool success){
        evaluatorList[msg.sender] = Evaluator(_name, 5, _expertiseDomain);
        return true;
    }
    
    function initFinancier(address _financierAddress, string memory _name) public returns (bool success){
        tokenContract.transferFrom(msg.sender, _financierAddress, 2);
        financierList[msg.sender] = Financier(_name);
        return true;
    }

    // function contributeToProduct(uint selectProd) external payable {
    //     require(msg.value != 0, "Please add an amount!");
        
    //     require();
    //     //product.totalSum
    // }
    
    //functie show produse
    function showProductId() public view returns (uint[] memory) {
        uint[] memory ret = new uint[](prodTotal);
        for (uint i = 0; i < prodTotal; i++) {
            if (productList[i].active)
                ret[i] = productList[i].id;
        }
        return ret;
    }
    
    // function showProductId() public view returns ( memory) {
    //     uint[] memory ret = new uint[](prodTotal);
    //     for (uint i = 0; i < prodTotal; i++) {
    //         ret[i] = productList[i].id;
    //     }
    //     return ret;
    // }
    
    //[prod1], [prod2]
    
    
    
    // function getAll() public view returns (address[] memory){
    //     address[] memory ret = new address[](addressRegistryCount);
    //     for (uint i = 0; i < addressRegistryCount; i++) {
    //         ret[i] = addresses[i];
    //     }
    //     return ret;
    // }
    
    
//     function append(string a, string b, string c, string d, string e) internal pure returns (string) {

//     return string(abi.encodePacked(a, b, c, d, e));

// }

    
    
    
    
    
    function contributeToProduct(uint productId, uint tokenAmount) external payable onlyFinancier() {
        require(tokenAmount != 0, "Please enter a valid amount!");
        require(productList[productId].balance < productList[productId].totalSum, "Goal reached.");
        uint check = productList[productId].balance + tokenAmount;
        require(check <= productList[productId].totalSum, "The amount is too big!");
        
        tokenContract.transferFrom(msg.sender, address(this), tokenAmount);
        productList[productId].balance += tokenAmount;
        productList[productId].finantare[msg.sender] += tokenAmount;
    }
    
    constructor(Token _tokenContract) public {
        owner = msg.sender;
        tokenContract = _tokenContract;
        prodTotal = 0;
    }
    
    function sendTokens(address ad, uint256 _numberOfTokens) public {
         
         tokenContract.transfer(ad, _numberOfTokens);
    }
    
    function getBalance() public view returns(uint256){
        return tokenContract.balanceOf(msg.sender);
    }
}

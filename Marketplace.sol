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
    uint prodTotal; 
    
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
        //address
    }

    struct Product {
        uint id;
        bool active;
        bool prodExists;
        string description;
        uint developingCost;
        uint evaluatorCompensation;
        uint balance;
        uint totalSum;
        string expertiseDomain;
        address associatedManager;
        mapping(address => uint) finantare;
        address[] finAddr;
    }

    mapping(address => Manager) public managerList;
    mapping(address => Freelancer) public freelencerList;
    mapping(address => Evaluator) public evaluatorList;
    mapping(address => Financier) public financierList;
    mapping(uint => Product) public productList; 
    
    modifier onlyManager(){
        require(bytes(managerList[msg.sender].name).length != 0, "You are not a manager");
        _;
    }
    
    modifier onlyFinancier(){
        require(bytes(financierList[msg.sender].name).length != 0, "You are not a financier");
        _;
    }
    
    modifier onlyFreelancer(){
        require(bytes(financierList[msg.sender].name).length != 0, "You are not a freelancer");
        _;
    }
    
    modifier onlyEvaluator(){
        require(bytes(financierList[msg.sender].name).length != 0, "You are not a evaluator");
        _;
    }
    
    constructor(Token _tokenContract) public {
        owner = msg.sender;
        tokenContract = _tokenContract;
        prodTotal = 0;
    }




    //functions for init manager, freelancer, evaluator, sponsor
    //ok
    function initManager(string memory _name) public returns (bool success){
        managerList[msg.sender] = Manager(_name, 5);
        return true;
    }
    
    //ok
    function initFreelancer(string memory _name, string memory _expertiseDomain) public returns (bool success){
        freelencerList[msg.sender] = Freelancer(_name, 5, _expertiseDomain);
        return true;
    }
    
    //ok
    function initEvaluator(string memory _name, string memory _expertiseDomain) public returns (bool success){
        evaluatorList[msg.sender] = Evaluator(_name, 5, _expertiseDomain);
        return true;
    }
    
    //ok
    function initFinancier(string memory _name) public returns (bool success){
        require(owner != msg.sender, "picat");
        tokenContract.transferFrom(owner, msg.sender, 10);
        financierList[msg.sender] = Financier(_name);
        return true;
    }




    // only to be called by managers
    //ok
    function managerAddProduct(string calldata prodDescription, uint developCost, uint evalCompensation, string calldata domainProd) external onlyManager() {
        uint totalSumProd = developCost + evalCompensation;
        prodTotal += 1;
        productList[prodTotal] = Product(prodTotal, true, true, prodDescription, developCost, evalCompensation, 0, totalSumProd, domainProd, msg.sender, new address[](0));
    }
    
    // only to be called by managers
    //ok
    function managerInactivateProduct(uint id) public onlyManager() {
        require(productList[id].prodExists == true, "Invalid product ID.");
        require(productList[id].balance < productList[id].totalSum, "The amount was reached, cannot inactivate product!");
        productList[id].active = false;
        
        uint returnBack = 0;
        uint getFinArrLength = productList[id].finAddr.length;
        if (getFinArrLength != 0){
            for(uint i = 0; i < getFinArrLength; i++){
                returnBack = productList[id].finantare[productList[id].finAddr[i]];
                tokenContract.transferFrom(address(this), productList[id].finAddr[i], returnBack);
                productList[id].balance -= returnBack;
                productList[id].finantare[productList[id].finAddr[i]] = 0;
            }
        }
    }
    
    // only to be called by managers
    //ok
    function managerShowInactiveProductsId() public onlyManager() view returns (uint[] memory) {
        uint[] memory ret = new uint[](prodTotal);
        uint contor = 0;
        for (uint i = 1; i <= prodTotal; i++) {
            if (productList[i].active == false)
                ret[contor] = productList[i].id;
                contor += 1;
        }
        return ret;
    }
    
    // only to be called by managers
    //ok
    function managerShowActiveProductsId() public onlyManager() view returns (uint[] memory) {
        uint[] memory ret = new uint[](prodTotal); 
        uint contor = 0;
        for (uint i = 1; i <= prodTotal; i++) {
            if (productList[i].active == true)
                ret[contor] = productList[i].id;
                contor += 1;
        }
        return ret;
    }
    
    // only to be called by managers
    //ok
    function managerShowAllProductsId() public onlyManager() view returns (uint[] memory) {
        uint[] memory ret = new uint[](prodTotal);
        uint contor = 0;
        for (uint i = 1; i <= prodTotal; i++) {
            ret[contor] = productList[i].id;
            contor += 1;
        }
        return ret;
    }
    
    
    
    
    
    
    // only to be called by financier
    function financierContributeToProduct(uint productId, uint tokenAmount) external payable onlyFinancier() {
        require(tokenAmount != 0, "Please enter a valid amount!");
        require(productList[productId].prodExists == true, "Invalid product ID.");
        require(productList[productId].balance < productList[productId].totalSum, "Goal reached.");
        uint check = productList[productId].balance + tokenAmount;
        require(check <= productList[productId].totalSum, "The amount is too big!");
        
        //merge pana aici
        uint getFinArrLength = productList[productId].finAddr.length;
        bool checkExistance = false;
        if (getFinArrLength != 0){
            for(uint i = 0; i < getFinArrLength; i++){
                if (productList[productId].finAddr[i] == msg.sender) {
                    checkExistance = true;
                    break;
                }
            }
        }
        
        //scazut tokenamount de la finan?
        if(checkExistance == false){
            productList[productId].finAddr.push(msg.sender);
        }
        tokenContract.transferFrom(msg.sender, owner, tokenAmount);
        productList[productId].balance += tokenAmount;
        productList[productId].finantare[msg.sender] += tokenAmount;
    }
    
    //only to be called by financier
    function financierRetrieveAmount(uint id) public onlyFinancier() {
        require(productList[id].prodExists == true, "Invalid product ID.");
        require(productList[id].balance < productList[id].totalSum, "The amount was reached, cannot inactivate product!");
        require(productList[id].finantare[msg.sender] > 0, "You didn't support this project yet.");
        tokenContract.transferFrom(address(this), msg.sender, productList[id].finantare[msg.sender]);
        productList[id].finantare[msg.sender] = 0;
    }
    
    //only managers and financiers can see
    //ok
    function mfShowUnfinancedActiveProductsId() public view returns (string memory result, uint[] memory) {
        if (bytes(managerList[msg.sender].name).length != 0 || bytes(financierList[msg.sender].name).length != 0){
            uint contor = 0;
            uint[] memory ret = new uint[](prodTotal);
            for (uint i = 1; i <= prodTotal; i++) {
                if (productList[i].active && productList[i].balance < productList[i].totalSum)
                    ret[contor] = productList[i].id;
                    contor += 1;
            }
            return ("Products ID: ", ret);
        }
        return ("You must be a manager or a financier.", new uint[](0));
    }
    
    
    
    
    //only managers, freelancers and evaluators can see
    //ok
    function showFinancedProductsId() public view returns (string memory result, uint[] memory) {
        if (bytes(managerList[msg.sender].name).length != 0 || bytes(freelencerList[msg.sender].name).length != 0 || bytes(evaluatorList[msg.sender].name).length != 0){
            uint[] memory ret = new uint[](prodTotal);
            uint contor = 0;
            for (uint i = 1; i <= prodTotal; i++) {
                if (productList[i].active && productList[i].balance == productList[i].totalSum)
                    ret[contor] = productList[i].id;
                    contor += 1;
            }
            return ("Products ID: ", ret);
        }
        return ("You must be a manager, freelancer or a evaluator.", new uint[](0));
    }
    
    //ok
    function showProductInfo(uint id) public view returns (string memory showDescr, uint showDev, uint showRev, uint showBalance, uint showTotal, string memory showDomain) {
        //uint showId, string memory showDescr, uint showDev, uint showRev, uint showBalance, uint showTotal, string memory showDomain
        //productList[id].id, productList[id].description, productList[id].developingCost, productList[id].evaluatorCompensation, productList[id].balance, productList[id].totalSum, productList[id].expertiseDomain
        require(productList[id].prodExists == true, "Invalid product ID.");
        
        if (bytes(managerList[msg.sender].name).length != 0) 
            return (productList[id].description, productList[id].developingCost, productList[id].evaluatorCompensation, productList[id].balance, productList[id].totalSum, productList[id].expertiseDomain);
        
        else if ((bytes(freelencerList[msg.sender].name).length != 0 || bytes(evaluatorList[msg.sender].name).length != 0)) {
            require(productList[id].active, "The product is inactive."); 
            require(productList[id].balance == productList[id].totalSum, "The product is either inactive or not financed.");
            return (productList[id].description, productList[id].developingCost, productList[id].evaluatorCompensation, productList[id].balance, productList[id].totalSum, productList[id].expertiseDomain);
        }
        else if (bytes(financierList[msg.sender].name).length != 0){
            require(productList[id].active, "The product is inactive."); 
            require(productList[id].balance < productList[id].totalSum, "The product is fully financed.");
            return (productList[id].description, productList[id].developingCost, productList[id].evaluatorCompensation, productList[id].balance, productList[id].totalSum, productList[id].expertiseDomain);
        }
    }
}
//https://ethereum.stackexchange.com/questions/51362/how-to-use-timer-in-escrow
//https://medium.com/coinmonks/testing-time-dependent-logic-in-ethereum-smart-contracts-1b24845c7f72

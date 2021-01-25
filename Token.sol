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
    mapping(uint => Product) public productList; //productList[Product.id]
    
    modifier onlyManager(){
        require(bytes(managerList[msg.sender].name).length != 0, "mesaj");
        _;
    }
    
    modifier onlyFinancier(){
        require(bytes(financierList[msg.sender].name).length != 0, "mesaj");
        _;
    }
    
    //add modifier pt onlymanager+financier
    //plus modifier pt restul

    constructor(Token _tokenContract) public {
        owner = msg.sender;
        tokenContract = _tokenContract;
        prodTotal = 0;
    }

    //functions for init manager, freelancer, evaluator, sponsor
    function initManager(string memory _name) public returns (bool success){
        managerList[msg.sender] = Manager(_name, 5);
        return true;
    }
    
    function initFreelancer(string memory _name, string memory _expertiseDomain) public returns (bool success){
        freelencerList[msg.sender] = Freelancer(_name, 5, _expertiseDomain);
        return true;
    }
    
    function initEvaluator(string memory _name, string memory _expertiseDomain) public returns (bool success){
        evaluatorList[msg.sender] = Evaluator(_name, 5, _expertiseDomain);
        return true;
    }
    
    //tokenContract.transferFrom(msg.sender, address(this), tokenAmount);
    function initFinancier(address _financierAddress, string memory _name) public returns (bool success){
        tokenContract.transferFrom(msg.sender, _financierAddress, 2);
        financierList[msg.sender] = Financier(_name);
        return true;
    }

    // only to be called by managers
    function addProduct(string calldata prodDescription, uint developCost, uint evalCompensation, string calldata domainProd) external onlyManager() {
        uint totalSumProd = developCost + evalCompensation;
        
        productList[prodTotal] = Product(prodTotal, true, prodDescription, developCost, evalCompensation, 0, totalSumProd, domainProd, msg.sender, new address[](0));
        prodTotal += 1;

    }
    
    // only to be called by financier
    function contributeToProduct(uint productId, uint tokenAmount) external payable onlyFinancier() {
        //check pentru existare product id
        require(tokenAmount != 0, "Please enter a valid amount!");
        require(productList[productId].balance < productList[productId].totalSum, "Goal reached.");
        uint check = productList[productId].balance + tokenAmount;
        require(check <= productList[productId].totalSum, "The amount is too big!");
        
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
        
        if(checkExistance == false){
            productList[productId].finAddr.push(msg.sender);
        }
        
        tokenContract.transferFrom(msg.sender, address(this), tokenAmount);
        productList[productId].balance += tokenAmount;
        productList[productId].finantare[msg.sender] += tokenAmount;
    }
    
    //retragere suma finantator
    function retrieveFinAmount(uint id) public onlyFinancier() {
        //check pentru existare product id
        require(productList[id].balance < productList[id].totalSum, "The amount was reached, cannot inactivate!");
        require(productList[id].finantare[msg.sender] > 0, "You didn't support this project yet.");
        tokenContract.transferFrom(address(this), msg.sender, productList[id].finantare[msg.sender]);
        productList[id].finantare[msg.sender] = 0;
    }
    
    
    // only to be called by managers
    function inactivateProduct(uint id) public onlyManager() {
        //check pentru existare product id
        require(productList[id].balance < productList[id].totalSum, "The amount was reached, cannot inactivate!");
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

    //functie show produse
    //+fct pt produsele in done pt ceilalti
    function showActiveProductsId() public view returns (uint[] memory) {
        //doar manager si finantator
        uint[] memory ret = new uint[](prodTotal);
        for (uint i = 0; i < prodTotal; i++) {
            if (productList[i].active)
                ret[i] = productList[i].id;
        }
        return ret;
    }
    
    function showInactiveProductsId() public onlyManager() view returns (uint[] memory) {
        uint[] memory ret = new uint[](prodTotal);
        for (uint i = 0; i < prodTotal; i++) {
            if (productList[i].active == false)
                ret[i] = productList[i].id;
        }
        return ret;
    }
    
    //de facut inca o fct pt restul
    function showProductInfo(uint id) public view returns (uint showId, string memory showDescr, uint showDev, uint showRev, uint showBalance, uint showTotal, string memory showDomain) {
        //doar manager si finantator
        //check pentru existare product id
        return (productList[id].id, productList[id].description, productList[id].developingCost, productList[id].evaluatorCompensation, productList[id].balance, productList[id].totalSum, productList[id].expertiseDomain);
    }
    
                    // uint[] array = [1,2,3,4,5];
                // function remove(uint index)  returns(uint[]) {
                //     if (index >= array.length) return;
            
                //     for (uint i = index; i<array.length-1; i++){
                //         array[i] = array[i+1];
                //     }
                //     delete array[array.length-1];
                //     array.length--;
                //     return array;
                // }  
}
//https://ethereum.stackexchange.com/questions/51362/how-to-use-timer-in-escrow

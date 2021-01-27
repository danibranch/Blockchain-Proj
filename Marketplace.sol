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
        uint contor; //how many projects did he apply to
        mapping (uint => uint) dev; //map the product id with the amount he gives for dev
        uint[] prodID; //remember list with products id's he applied to
    }

    struct Evaluator {
        string name;
        uint reputation;
        string expertiseDomain;
        bool applied; //check if he applied for a product
        uint prodID; //remember product id
    }
    
    struct Financier {
        string name;
    }

    struct Product {
        uint id;
        string description;
        uint developingCost; //dev
        uint devRaised; //the amount raised by freelancers till now, it has to reach evaluatorCompensation
        uint evaluatorCompensation; //rev
        uint balance; //the amount raised by financiers till now, it has to reach totalSum
        uint totalSum; //total for DEV and REV
        string expertiseDomain;
        bool active; //check if the product is active or inactive
        bool prodExists; //check if the product exists, true by default
        
        //map the address of the financier with the amount he gives and remember a list with the financiers addresses
        mapping(address => uint) finantare;
        address[] finAddr;
        
        //map the address of the freelancer with the amount he gives and remember a list with the freelancers addresses
        mapping(address => uint) freelancer;
        address[] freelancerAddr;
        
        //final freelancers
        address[] finalFreelancersAddr;
        
        address evaluatorAddress;
    }
    
    struct prodBools {
        bool wasArbitraj; 
        bool arbitraj;
        bool freelancersWorkIsDone;
        bool managerAcceptProductResult;
        bool duringExecution; //check if the product is in the execution mode
        bool isFinalized;
    }

    mapping(address => Manager) public managerList;
    mapping(address => Freelancer) public freelencerList;
    mapping(address => Evaluator) public evaluatorList;
    mapping(address => Financier) public financierList;
    mapping(uint => Product) public productList; 
    mapping(uint => prodBools) public productCheckList;
    
    modifier onlyManager(){
        require(bytes(managerList[msg.sender].name).length != 0, "You are not a manager");
        _;
    }
    
    modifier onlyFinancier(){
        require(bytes(financierList[msg.sender].name).length != 0, "You are not a financier");
        _;
    }
    
    modifier onlyFreelancer(){
        require(bytes(freelencerList[msg.sender].name).length != 0, "You are not a freelancer");
        _;
    }
    
    modifier onlyEvaluator(){
        require(bytes(evaluatorList[msg.sender].name).length != 0, "You are not a evaluator");
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
        freelencerList[msg.sender] = Freelancer(_name, 5, _expertiseDomain, 0, new uint[](4));
        return true;
    }
    
    //ok
    function initEvaluator(string memory _name, string memory _expertiseDomain) public returns (bool success){
        evaluatorList[msg.sender] = Evaluator(_name, 5, _expertiseDomain, false, 0);
        return true;
    }
    
    //ok
    function initFinancier(string memory _name) public returns (bool success){
        tokenContract.transferFrom(owner, msg.sender, 10);
        financierList[msg.sender] = Financier(_name);
        return true;
    }
    
    function showRep() public view returns(uint Reputiation){
        if (bytes(managerList[msg.sender].name).length != 0) {
            return managerList[msg.sender].reputation;
        }
        if (bytes(freelencerList[msg.sender].name).length != 0) {
            return freelencerList[msg.sender].reputation;
        }
        if (bytes(evaluatorList[msg.sender].name).length != 0) {
            return evaluatorList[msg.sender].reputation;
        }
    }

    // only to be called by managers, add products
    //ok
    function addProduct(string calldata prodDescription, uint developCost, uint evalCompensation, string calldata domainProd) external onlyManager() {
        prodTotal += 1;
        productList[prodTotal] = Product(prodTotal, prodDescription, developCost, 0, evalCompensation, 0, developCost + evalCompensation, domainProd, true, true, new address[](0), new address[](0), new address[](0), address(0) );
        productCheckList[prodTotal] = prodBools(false, false, false, false, false, false);
        
    }
    
    // only to be called by managers, inactivate a product
    //ok
    function inactivateProduct(uint id) public onlyManager() {
        require(productList[id].prodExists == true, "Invalid product ID.");
        require(productList[id].balance < productList[id].totalSum, "The amount was reached, cannot inactivate product!");
        productList[id].active = false;
        
        if ( productList[id].finAddr.length != 0){
            for(uint i = 0; i <  productList[id].finAddr.length; i++){
                tokenContract.transfer(productList[id].finAddr[i], productList[id].finantare[productList[id].finAddr[i]]);
                productList[id].balance -= productList[id].finantare[productList[id].finAddr[i]];
                productList[id].finantare[productList[id].finAddr[i]] = 0;
            }
        }
    }
    
    // only to be called by managers, view inactive products
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
    
    // only to be called by managers, view active products
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
    
    // only to be called by managers, view all active and inactive products
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
    
    //ok
    // only to be called by financier, contribute to project
    function financierContributeToProduct(uint productId, uint tokenAmount) public onlyFinancier() {
        require(tokenAmount != 0, "Please enter a valid amount!");
        require(productList[productId].prodExists == true, "Invalid product ID.");
        require(productList[productId].balance < productList[productId].totalSum, "Goal reached.");
        require(productList[productId].active == true, "The product is not active!" );
        require(productList[productId].balance + tokenAmount <= productList[productId].totalSum, "The amount is too big!");
        
       
        bool checkExistance = false;
        if (productList[productId].finAddr.length != 0){
            for(uint i = 0; i < productList[productId].finAddr.length; i++){
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
    
    
    //only to be called by financier, get amount back from project
    //ok
    function financierRetrieveAmount(uint id) public onlyFinancier() {
        require(productList[id].prodExists == true, "Invalid product ID.");
        require(productList[id].balance < productList[id].totalSum, "The amount was reached, cannot inactivate product!");
        require(productList[id].finantare[msg.sender] > 0, "You didn't support this project yet.");
        tokenContract.transfer(msg.sender, productList[id].finantare[msg.sender]);
        productList[id].balance -= productList[id].finantare[msg.sender];
        productList[id].finantare[msg.sender] = 0;
    }
    
    //only managers and financiers can see the unfinanced projects
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
    
    //only managers, freelancers and evaluators can see the financed projects
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
    
    //show product info depending on the user's type
    //ok
    function showProductInfo(uint id) public view returns (string memory showDescr, uint showDev, uint showRev, uint showBalance, uint showTotal, string memory showDomain) {
        require(productList[id].prodExists == true, "Invalid product ID.");
        
        if (bytes(managerList[msg.sender].name).length != 0) 
            return (productList[id].description, productList[id].developingCost, productList[id].evaluatorCompensation, productList[id].balance, productList[id].totalSum, productList[id].expertiseDomain);
        
        else if ((bytes(freelencerList[msg.sender].name).length != 0 || bytes(evaluatorList[msg.sender].name).length != 0)) {
            require(productList[id].active, "The product is inactive."); 
            require(productList[id].balance == productList[id].totalSum, "The product is not financed.");
            return (productList[id].description, productList[id].developingCost, productList[id].evaluatorCompensation, productList[id].balance, productList[id].totalSum, productList[id].expertiseDomain);
        }
        else if (bytes(financierList[msg.sender].name).length != 0){
            require(productList[id].active, "The product is inactive."); 
            require(productList[id].balance < productList[id].totalSum, "The product is fully financed.");
            return (productList[id].description, productList[id].developingCost, productList[id].evaluatorCompensation, productList[id].balance, productList[id].totalSum, productList[id].expertiseDomain);
        }
    }

    //only to be called by evaluators, allow apply to only one project
    //ok
    function evaluatorApplyProductId(uint id) public onlyEvaluator(){
        require(productList[id].prodExists == true, "Invalid product ID.");
        require(productList[id].active, "The product is inactive."); 
        require(productList[id].balance == productList[id].totalSum, "The product is not financed.");
        require(evaluatorList[msg.sender].applied == false, "You have already applied to a projet.");
        require(keccak256(bytes(productList[id].expertiseDomain)) == keccak256(bytes(evaluatorList[msg.sender].expertiseDomain)), "Your xpertise domain does not match the expertise of the selected product.");

        evaluatorList[msg.sender].prodID = id;
        evaluatorList[msg.sender].applied = true;
        productList[id].evaluatorAddress =  msg.sender;
    }

    
    //only to be called by freelancers, allow apply to more projects
    //ok
    function freelancerApplyProductId(uint id, uint amount) public onlyFreelancer(){
    //trebuie retinut cat da fiecare freelancer pe un proiect plus care e proiectul(id) (mapping)
    //contor pentru a face array-ul cu id
    //trebuie stiut la fiecare proiect o lista cu freelancerii care au aplicat(addrs) si valoarea
    //presume that the domain is only one
        require(productList[id].prodExists == true, "Invalid product ID.");
        require(productList[id].active, "The product is inactive."); 
        require(productList[id].balance == productList[id].totalSum, "The product is not financed.");
        require(productList[id].developingCost >= amount, "The amount is too big.");
        require(keccak256(bytes(productList[id].expertiseDomain)) == keccak256(bytes(freelencerList[msg.sender].expertiseDomain)), "You need to be expert for this product's domain");
        
        freelencerList[msg.sender].contor += 1;
        freelencerList[msg.sender].prodID[freelencerList[msg.sender].contor] = id;
        freelencerList[msg.sender].dev[id] = amount;
        
        productList[id].freelancer[msg.sender] = amount;
        productList[id].freelancerAddr.push(msg.sender);
    }
    
    // //only to be called by manager
    // function managerViewFreelancersId() public onlyManager() view returns (uint[] memory) {
    //     uint[] memory ret = new uint[](prodTotal);
    //     uint contor = 0;
    //     for (uint i = 1; i <= prodTotal; i++) {
    //         if (productList[i].active == false)
    //             ret[contor] = productList[i].id;
    //             contor += 1;
    //     }
    //     return ret;
    // }
    
    //manager can see the freelancers for a certain project (id)
    //ok
    function managerShowFreelancersForProjectId(uint id) public view onlyManager() returns(address[] memory){
        return productList[id].freelancerAddr;
    }
    
    //managerul poate verifica cu cat doreste un freelancer sa aplice pe proiectul x + reputatia-> input id proiect, id freelancer, output suma oferita de freelancer, reputatia
    //ok
    function managerShowFreelancerAddressInfo(uint prodId, address adr)public view onlyManager() returns(uint amount, uint reputation){
        require(productList[prodId].prodExists == true, "Invalid product ID.");
        require(productList[prodId].active, "The product is inactive."); 
        require(productList[prodId].balance == productList[prodId].totalSum, "The product is not financed.");
        require(productList[prodId].freelancer[adr] != 0, "The freelancer doesn't exist with this product id.");
        return (productList[prodId].freelancer[adr], freelencerList[adr].reputation);
    }
    
    //manager creates the final list for freelancers for a certain product so the project can start
    //ok
    function managerAddFinalFreelancer(uint prodId, address adr) public onlyManager() {
        require(productList[prodId].prodExists == true, "Invalid product ID.");
        require(productList[prodId].active == true, "The product is inactive."); 
        require(productList[prodId].balance == productList[prodId].totalSum, "The product is not financed.");
        require(productList[prodId].freelancer[adr] != 0, "The freelancer doesn't exist with this product id.");
        require(productList[prodId].devRaised + productList[prodId].freelancer[adr] <= productList[prodId].developingCost, "The amount is too much.");
        require(productCheckList[prodId].duringExecution == false, "The product is in execution mode."); 

        bool check = false;
        for(uint i=0; i<productList[prodId].finalFreelancersAddr.length; i++ ){
            if(productList[prodId].finalFreelancersAddr[i] == adr){
                check = true;
                break;
            }
        }
        if(check == false){
            productList[prodId].finalFreelancersAddr.push(adr);
        }
        productList[prodId].devRaised += productList[prodId].freelancer[adr];
        if(productList[prodId].devRaised == productList[prodId].developingCost){
            productCheckList[prodId].duringExecution = true;
        }
    }
    
    //freelancer marks a product as done/finished
    //ok
    function freelancerMarkProductAsDone(uint prodId) public onlyFreelancer(){
        require(productList[prodId].prodExists == true, "Invalid product ID.");
        require(productList[prodId].active == true, "The product is inactive."); 
        require(productList[prodId].balance == productList[prodId].totalSum, "The product is not financed.");
        require(productCheckList[prodId].duringExecution == true, "The product is not in execution."); 
        
         for(uint i=0; i<productList[prodId].finalFreelancersAddr.length; i++ ){
            if(productList[prodId].finalFreelancersAddr[i] == msg.sender){
                 productCheckList[prodId].freelancersWorkIsDone = true;
            }
        }
    }
    
    //manager can check if the work on a project is done
    //ok
    function managerCheckIfFreelancersWorkIsDone(uint prodId) public view onlyManager() returns(bool){
        require(productList[prodId].prodExists == true, "Invalid product ID.");
        require(productList[prodId].active == true, "The product is inactive."); 
        require(productList[prodId].balance == productList[prodId].totalSum, "The product is not financed.");
        return  productCheckList[prodId].freelancersWorkIsDone;
    }
    

    //manager can accept the result from freelancers for a certain product
    //ok
    function managerAcceptProductResult(uint prodId) public onlyManager() {
        require(productList[prodId].prodExists == true, "Invalid product ID.");
        require(productList[prodId].active == true, "The product is inactive."); 
        require(productList[prodId].balance == productList[prodId].totalSum, "The product is not financed.");
        require(productCheckList[prodId].freelancersWorkIsDone == true, "The freelancers work is not done.");
        
        productCheckList[prodId].managerAcceptProductResult = true;
        
        for(uint i=0; i<productList[prodId].finalFreelancersAddr.length; i++ ){
            tokenContract.transfer(productList[prodId].finalFreelancersAddr[i], productList[prodId].freelancer[productList[prodId].finalFreelancersAddr[i]]);
            productList[prodId].devRaised -= productList[prodId].freelancer[productList[prodId].finalFreelancersAddr[i]];
            productList[prodId].balance -= productList[prodId].freelancer[productList[prodId].finalFreelancersAddr[i]];
            if(freelencerList[productList[prodId].finalFreelancersAddr[i]].reputation < 10){
                freelencerList[productList[prodId].finalFreelancersAddr[i]].reputation += 1;
            }
        }
        productList[prodId].active = false;
        productCheckList[prodId].duringExecution = false;
        productCheckList[prodId].isFinalized = true;
       
        if(productCheckList[prodId].wasArbitraj == false){
            tokenContract.transfer(msg.sender, productList[prodId].balance);
            if(managerList[msg.sender].reputation < 10){
                managerList[msg.sender].reputation += 1;
            }
        }
        else{
            tokenContract.transfer(productList[prodId].evaluatorAddress, productList[prodId].evaluatorCompensation);
        }
    }
    
    //manager can decline the result and set it to arbitraj
    
    function managerDeclineProductResult(uint prodId) public onlyManager() {
        require(productList[prodId].prodExists == true, "Invalid product ID.");
        require(productList[prodId].active == true, "The product is inactive."); 
        require(productList[prodId].balance == productList[prodId].totalSum, "The product is not financed.");
        require(productCheckList[prodId].freelancersWorkIsDone == true, "The freelancers work is not done.");
        require(productCheckList[prodId].arbitraj == false, "Arbitraj exists.");
        productCheckList[prodId].arbitraj = true;
        if(productCheckList[prodId].wasArbitraj == false){
            productCheckList[prodId].wasArbitraj = true;
        }
    }

    //evaluator checks the arbitraj mode
    function evaluatorCheckIfArbitraj(uint prodId) public view onlyEvaluator() returns(bool){
        require(evaluatorList[msg.sender].prodID == prodId, "You've applied for another product.");
        require(productList[prodId].prodExists == true, "Invalid product ID.");
        require(productList[prodId].active == true, "The product is inactive."); 
        require(productList[prodId].balance == productList[prodId].totalSum, "The product is not financed.");
        require(productCheckList[prodId].freelancersWorkIsDone == true, "Freelancers work is not done.");
        require(productCheckList[prodId].managerAcceptProductResult == false, "Manager accepted the freelancers work.");
        require(productCheckList[prodId].isFinalized == false, "Product is finalized.");
        return  productCheckList[prodId].arbitraj;
    }
     
    //evaluator can accept a product after arbitraj was set
    //ok
    function evaluatorAcceptProductResult(uint prodId) public onlyEvaluator() {
        require(evaluatorList[msg.sender].prodID == prodId, "You've applied for another product.");
        require(productList[prodId].prodExists == true, "Invalid product ID.");
        require(productList[prodId].active == true, "The product is inactive."); 
        require(productList[prodId].balance == productList[prodId].totalSum, "The product is not financed.");
        require(productCheckList[prodId].freelancersWorkIsDone == true, "The freelancers work is not done.");
        require(productCheckList[prodId].arbitraj == true, "Arbitraj does not exist.");
        require(productCheckList[prodId].managerAcceptProductResult == false, "Manager accepted the freelancers work.");
        require(productCheckList[prodId].isFinalized == false, "Product is finalized.");
        
        
        for(uint i=0; i<productList[prodId].finalFreelancersAddr.length; i++ ){
            tokenContract.transfer(productList[prodId].finalFreelancersAddr[i], productList[prodId].freelancer[productList[prodId].finalFreelancersAddr[i]]);
            productList[prodId].devRaised -= productList[prodId].freelancer[productList[prodId].finalFreelancersAddr[i]];
            productList[prodId].balance -= productList[prodId].freelancer[productList[prodId].finalFreelancersAddr[i]];
            
            if(freelencerList[productList[prodId].finalFreelancersAddr[i]].reputation < 10){
                freelencerList[productList[prodId].finalFreelancersAddr[i]].reputation += 1;
            }
        }
        
        productList[prodId].active = false;
        productCheckList[prodId].duringExecution = false;
        productCheckList[prodId].isFinalized = true;
        productCheckList[prodId].arbitraj = false;
        
        if(managerList[msg.sender].reputation > 1){
            managerList[msg.sender].reputation -= 1;
        }
        tokenContract.transfer(msg.sender, productList[prodId].evaluatorCompensation);
        evaluatorList[msg.sender].prodID = 0;
        evaluatorList[msg.sender].applied = false;
    }
    
    //evaluator can decline a product after arbitraj was set
    //ok
    function evaluatorDeclineProductResult(uint prodId) public onlyManager() {
        require(evaluatorList[msg.sender].prodID == prodId, "You've applied for another product.");
        require(productList[prodId].prodExists == true, "Invalid product ID.");
        require(productList[prodId].active == true, "The product is inactive."); 
        require(productList[prodId].balance == productList[prodId].totalSum, "The product is not financed.");
        require(productCheckList[prodId].freelancersWorkIsDone == true, "The freelancers work is not done.");
        require(productCheckList[prodId].arbitraj == true, "Arbitraj does not exist.");
        require(productCheckList[prodId].managerAcceptProductResult == false, "Manager accepted the freelancers work.");
        require(productCheckList[prodId].isFinalized == false, "Product is finalized.");
        
        productCheckList[prodId].arbitraj = false;
        productCheckList[prodId].freelancersWorkIsDone = false;
        productCheckList[prodId].managerAcceptProductResult = false;
        productCheckList[prodId].duringExecution = false;
        productList[prodId].devRaised = 0;
        productCheckList[prodId].freelancersWorkIsDone = false;
        
        for(uint i=0; i<productList[prodId].finalFreelancersAddr.length; i++ ){
            if(freelencerList[productList[prodId].finalFreelancersAddr[i]].reputation >1 ){
                freelencerList[productList[prodId].finalFreelancersAddr[i]].reputation -= 1;
            }
        }
        productList[prodId].finalFreelancersAddr = new address[](0); 
    }
    
    
    // function managerDeleteFinalFreelancer(uint prodId, address adr)public{
    //     require(productList[prodId].prodExists == true, "Invalid product ID.");
    //     require(productList[prodId].active, "The product is inactive."); 
    //     require(productList[prodId].balance == productList[prodId].totalSum, "The product is not financed.");
    //     require(productList[prodId].freelancer[adr] != 0, "The freelancer doesn't exist with this product id.");
        
    //     bool check = false;
    //     for(uint i=0; i<productList[prodId].finalFreelancersAddr.length; i++ ){
    //         if(productList[prodId].finalFreelancersAddr[i] == adr){
    //             check = true;
    //             for (uint j = i; j<productList[prodId].finalFreelancersAddr.length-1; j++){
    //                 productList[prodId].finalFreelancersAddr[j] = productList[prodId].finalFreelancersAddr[j+1];
    //              }
    //              delete productList[prodId].finalFreelancersAddr[productList[prodId].finalFreelancersAddr.length-1];
    //              productList[prodId].finalFreelancersAddr.length--;
    //             break;
    //         }
    //     }
        
        
    //     //delete array[array.length-1];
    //     //array.length--;
    //   // return array;
    // }
    
    
    function balanceOf() public view returns(uint){
        return tokenContract.balanceOf(msg.sender);
    }
}

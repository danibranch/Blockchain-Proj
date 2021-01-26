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
        uint[] prodID; //remember list with rpoducts id's he applied to
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
        bool active; //check if the product is active or inactive
        bool prodExists; //check if the product exists, true by default
        bool duringExecution; //check if the product is in the execution mode
        string description;
        uint developingCost;
        uint devRaised; //the amount raised by freelancers till now, it has to reach evaluatorCompensation
        uint evaluatorCompensation;
        uint balance; //the amount raised by financiers till now, it has to reach totalSum
        uint totalSum; //total for DEV and REV
        bool freelancerClosing;
        string expertiseDomain;
        address associatedManager;
        
        //map the address of the financier with the amount he gives and remember a list with the financiers addresses
        mapping(address => uint) finantare;
        address[] finAddr;
        
        //map the address of the freelancer with the amount he gives and remember a list with the freelancers addresses
        mapping(address => uint) freelancer;
        address[] freelancerAddr;
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
        freelencerList[msg.sender] = Freelancer(_name, 5, _expertiseDomain, 0, new uint[](0));
        return true;
    }
    
    //ok
    function initEvaluator(string memory _name, string memory _expertiseDomain) public returns (bool success){
        evaluatorList[msg.sender] = Evaluator(_name, 5, _expertiseDomain, false, 0);
        return true;
    }
    
    //ok
    function initFinancier(string memory _name) public returns (bool success){
        require(owner != msg.sender, "picat");
        tokenContract.transferFrom(owner, msg.sender, 10);
        financierList[msg.sender] = Financier(_name);
        return true;
    }




    // only to be called by managers, add products
    //ok
    function addProduct(string calldata prodDescription, uint developCost, uint evalCompensation, string calldata domainProd) returns (uint id) external onlyManager() {
        uint totalSumProd = developCost + evalCompensation;
        prodTotal += 1;
        productList[prodTotal] = Product(prodTotal, true, true, false, prodDescription, developCost, 0, evalCompensation, 0, totalSumProd, false, domainProd, msg.sender, new address[](0), new address[](0));
        return prodTotal;
    }
    
    // only to be called by managers, inactivate a product
    function inactivateProduct(uint id) public onlyManager() {
        require(productList[id].prodExists == true, "Invalid product ID.");
        require(productList[id].balance < productList[id].totalSum, "The amount was reached, cannot inactivate product!");
        require(productList[id].associatedManager == msg.sender, "You don't own this product");
        productList[id].active = false;
        
        uint returnBack = 0;
        uint getFinArrLength = productList[id].finAddr.length;
        if (getFinArrLength != 0){
            for(uint i = 0; i < getFinArrLength; i++){
                returnBack = productList[id].finantare[productList[id].finAddr[i]];
                tokenContract.transfer(productList[id].finAddr[i], returnBack);
                productList[id].balance -= returnBack;
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
        require(Token.balanceOf(msg.sender) > 0, "You don't have enough tokens");
        require(Token.allowance(msg.sender, address(this)) >= tokenAmount, "You haven't allowed the contract to transfer enough tokens");
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
        
        //scazut tokenamount de la finantator?
        if(checkExistance == false){
            productList[productId].finAddr.push(msg.sender);
        }
       // tokenContract.approve(address(this),tokenAmount);     //F:0,1,1 ; F:1,0,1 
       // tokenContract.approve(msg.sender,tokenAmount);      
         
        tokenContract.transferFrom(msg.sender, address(this), tokenAmount);
        
        productList[productId].balance += tokenAmount;
        productList[productId].finantare[msg.sender] += tokenAmount;
    }
    
    
    //only to be called by financier, get amount back from project
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
        //uint showId, string memory showDescr, uint showDev, uint showRev, uint showBalance, uint showTotal, string memory showDomain
        //productList[id].id, productList[id].description, productList[id].developingCost, productList[id].evaluatorCompensation, productList[id].balance, productList[id].totalSum, productList[id].expertiseDomain
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
    function evaluatorApplyProductId(uint id) public onlyEvaluator(){
        require(productList[id].prodExists == true, "Invalid product ID.");
        require(productList[id].active, "The product is inactive."); 
        require(productList[id].balance == productList[id].totalSum, "The product is not financed.");
        require(evaluatorList[msg.sender].applied == false, "You have already applied to a projet.");
        
        evaluatorList[msg.sender].prodID = id;
        evaluatorList[msg.sender].applied = true;
    }
    
    function evaluatorRemoveProductId(uint id) public onlyEvaluator(){
        
    }
    
    //only to be called by freelancers, allow apply to more projects
    function freelancerApplyProductId(uint id, uint amount) public onlyFreelancer(){
    //trebuie retinut cat da fiecare freelancer pe un proiect plus care e proiectul(id) (mapping)
    //contor pentru a face array-ul cu id
    //trebuie stiut la fiecare proiect o lista cu freelancerii care au aplicat(addrs) si valoarea
    //presume that the domain is only one
        require(productList[id].prodExists == true, "Invalid product ID.");
        require(productList[id].active, "The product is inactive."); 
        require(productList[id].balance == productList[id].totalSum, "The product is not financed.");
        require(productList[id].developingCost >= amount, "The amount is too big.");
        // require(productList[id].devRaised + amount <= productList[id].developingCost, "Developing cost already reached.");
        require(keccak256(bytes(productList[id].expertiseDomain)) == keccak256(bytes(freelencerList[msg.sender].expertiseDomain)), "You need to be expert for this product's domain");
        
        freelencerList[msg.sender].contor += 1;
        freelencerList[msg.sender].prodID[freelencerList[msg.sender].contor] = id;
        freelencerList[msg.sender].dev[id] = amount;
        
        productList[id].freelancer[msg.sender] = amount;
        productList[id].freelancerAddr.push(msg.sender);
    }
    
    //only to be called by manager, view freelancer's id's
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
    
    
    //managerul trebuie sa vada lista de freelanceri la un proiect -> input id proiect output id freelancer
    //un id freelancer e asociat cu adresa acestuia, id unic (ca la produse)
    function managerShowFreelancersForProjectId(uint id) public returns(address[] memory){
        return productList[id].freelancerAddr;
    }
    
    function managerShowFreelancerAddressInfo(address adr)public{
        
    }
    
    
    //managerul poate verifica cu cat doreste un freelancer sa aplice pe proiectul x + reputatia-> input id proiect, id freelancer, output suma oferita de freelancer, reputatia
    
    //managerul poate sa aleaga echipa -> trebuie input de la manager cu o lista de id-uri ale freelancer ilor cum? se presupune ca trebuie ales din prima echipa potrivita si dev nu se restituie
    //se pune true pe during execution dupa ce check la echipa e ok (adica suma atinsa e == cu cea de la proiect)
    
    //freelancer modifica statusul de closed la prod si trimite notificare(cum?) -> input id proiect, modificare bool la proiect
    //se verifica daca proiectul x contine in lista definitiva de echipa freelancerul si daca este during execution => se modifica during si se trece in closed
    //managerul accepta sau nu -> input id proiect,
    
    
    
    
    function managerChooseProductTeam() public onlyManager () {
        
    }
    
    // function freelancerRemoveProductId(uint id) public onlyFreelancer(){
        
    // }
    
    
    
    function balanceOf() public view returns(uint){
        return tokenContract.balanceOf(msg.sender);
    }
    
    
    
    
    
    
    
    
    
    
}




//https://ethereum.stackexchange.com/questions/10932/how-to-convert-string-to-int
//https://ethereum.stackexchange.com/questions/51362/how-to-use-timer-in-escrow
//https://medium.com/coinmonks/testing-time-dependent-logic-in-ethereum-smart-contracts-1b24845c7f72

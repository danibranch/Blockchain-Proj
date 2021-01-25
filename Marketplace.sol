pragma solidity ^0.6.2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.3.0/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {

    constructor () public ERC20("Token", "TKN") {
        _mint(msg.sender, 1000000 * (10 ** uint256(decimals())));
    }
}


contract SampleTokenSale {
    Token tokenContract;
    address owner;
    uint8 prodID;
    
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
        string description;
        uint developingCost;
        uint evaluatorCompensation;
        uint totalSum;
        string expertiseDomain;
        address associatedManager;
        
        uint financerNumber;
        mapping(uint => ProdFinancing) financing;
    }
    


    struct ProdFinancing {
        address Financer;
        uint amountFinanced;
    }


    mapping(address => Manager) public managerList;
    mapping(address => Freelancer) public freelencerList;
    mapping(address => Evaluator) public evaluatorList;
    mapping(address => Financier) public financierList;
    mapping(address => Product[]) public managerToProduct;
    // mapping(address => )

// addProiect -> (addfinanatator, suma)
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
    

    //function for init manager, freelancer, evaluator, sponsor
    function initManager(string memory _name) public returns (bool success){
        managerList[msg.sender] = Manager(_name, 5);
        return true;
    }
    
    function addProduct(string calldata prodDescription, uint developCost, uint evalCompensation, uint8 totalSumProd, string calldata domainProd) external onlyManager() {
        managerToProduct[msg.sender].push(Product(prodDescription, developCost, evalCompensation, totalSumProd, domainProd, msg.sender, 0));
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

    // only to be called by managers
    function removeProduct(string calldata id) public {
    }
    
        constructor(Token _tokenContract) public {
        owner = msg.sender;
        tokenContract = _tokenContract;
    }
    
    function sendTokens(address ad, uint256 _numberOfTokens) public payable {
         
         tokenContract.transfer(ad, _numberOfTokens);
    }
    
    function getBalance() public view returns(uint256){
        return tokenContract.balanceOf(msg.sender);
    }
}

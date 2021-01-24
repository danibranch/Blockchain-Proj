pragma solidity >=0.7.0 <0.8.0;

contract Marketplace {
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

    struct Product {
        string id;
        string description;
        uint developingCost;
        uint evaluatorCompensation;
        string expertiseDomain;
        address associatedManager;
    }

    mapping(address => Manager) managerList;
    mapping(address => Freelancer) freelencerList;
    mapping(address => Evaluator) evaluatorList;
    mapping(address => mapping(string => Product)) productLists;

    constructor() public {

    }

    function initializeMarketplace() public {
        // managerList.push(Manager("M1", 5));
        // managerList.push(Manager("M2", 5));
        // freelencerList.push(Freelancer("F1", 5, "blockchain"));
        // freelencerList.push(Freelancer("F2", 5, "web"));
        // evaluatorList.push(Evaluator("E1", 5, "blockchain"));
        // evaluatorList.push(Evaluator("E2", 5, "web"));
    }

    // only to be called by managers
    function createProduct(string calldata id, string calldata descr, uint dev, uint rev, string calldata domain) public {
        // check that there isn't another id for the manager

        productLists[msg.sender][id] = Product(id, descr, dev, rev, domain, msg.sender);
    }

    // only to be called by managers
    function removeProduct(string calldata id) public {
        
    }
}
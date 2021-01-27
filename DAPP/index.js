const marketplaceABI = [
    {
        "type": "constructor",
        "stateMutability": "non-payable",
        "inputs": [
            {
                "type": "Token",
                "name": "_tokenContract"
            }
        ]
    },
    {
        "type": "function", 
        "name": "initManager",
        "inputs": [{
            "type": "string",
            "name": "_name"
        }],
        "outputs": [
            {
                "type": "bool",
                "name": "success"
            }
        ]
    },
    {
        "type": "function",
        "name": "initFreelancer",
        "inputs": [
            {
                "type": "string",
                "name": "_name"
            },
            {
                "type": "string",
                "name": "_expertiseDomain"
            }
        ],
        "outputs": [
            {
                "type": "bool",
                "name": "success"
            }
        ]
    },
    {
        "type": "function",
        "name": "initEvaluator",
        "inputs": [
            {
                "type": "string",
                "name": "_name"
            },
            {
                "type": "string",
                "name": "_expertiseDomain"
            }
        ],
        "outputs": [
            {
                "type": "bool",
                "name": "success"
            }
        ]
    },
    {
        "type": "function",
        "name": "initFinancier",
        "inputs": [
            {
                "type": "string",
                "name": "_name"
            }
        ],
        "outputs": [
            {
                "type": "bool",
                "name": "success"
            }
        ]
    },
    {
        "type": "function",
        "name": "addProduct",
        "inputs": [
            {
                "type": "string",
                "name": "prodDescription"
            },
            {
                "type": "uint",
                "name": "developCost"
            },
            {
                "type": "uint",
                "name": "evalCompensation"
            },
            {
                "type": "string",
                "name": "domainProd"
            }
        ],
        "outputs": [
            {
                "type": "uint",
                "name": "id"
            }
        ]
    },
    {
        "type": "function",
        "name": "inactivateProduct",
        "inputs": [
            {
                "type": "uint",
                "name": "id"
            }
        ]
    },
    {
        "type": "function",
        "name": "managerShowInactiveProductsId",
        "inputs": [],
        "outputs": [
            {
                "type": "uint[]",
                "name": "memory"
            }
        ]
    },
    {
        "type": "function",
        "name": "managerShowActiveProductsId",
        "inputs": [],
        "outputs": [
            {
                "type": "uint[]",
                "name": ""
            }
        ]
    },
    {
        "type": "function",
        "name": "managerShowAllProductsId",
        "inputs": [],
        "outputs": [
            {
                "type": "uint[]",
                "name": ""
            }
        ]
    },
    {
        "type": "function",
        "name": "financierContributeToProduct",
        "inputs": [
            {
                "type": "uint",
                "name": "productId"
            },
            {
                "type": "uint",
                "name": "tokenAmount"
            }
        ]
    },
    {
        "type": "function",
        "name": "financierRetrieveAmount",
        "inputs": [
            {
                "type": "uint",
                "name": "id"
            }
        ]
    }
]
const contractAddress = "0xf7d17B4bf802FA6065C61723c35512575BEeBE70"

const ethEnabled = () => {
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum);
      return true;
    }
    return false;
}
  
if (!ethEnabled()) {
      alert("Please install an Ethereum-compatible browser or extension like MetaMask to use this dApp!");
}

window.onload = async function init(){
    const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
    window.marketplace = new web3.eth.Contract(marketplaceABI, contractAddress);
    window.user = accounts[0]
}

ethereum.on('accountsChanged', function (accounts) {
    window.user = accounts[0]
});

function initManager() {
    let managerName = document.getElementById("initializeManagerName").value
    marketplace.methods.initManager(managerName).call({
        from: window.user
    }).then(result => {
        $("#initializeManagerResult").html(result)
        $("#initializeManagerResult").css("color", "green")
    }).catch(error => {
        $("#initializeManagerResult").html(error)
        $("#initializeManagerResult").css("color", "red")
    })
}

function initFreelancer() {
    let freelancerName = document.getElementById("initializeFreelancerName").value
    let freelancerDomain = document.getElementById("initializeFreelancerDomain").value
    marketplace.methods.initFreelancer(freelancerName, freelancerDomain).call({
        from: window.user
    }).then(console.log)
}

function initEvaluator() {
    let evaluatorName = document.getElementById("initializeEvaluatorName").value
    let evaluatorDomain = document.getElementById("initializeEvaluatorDomain").value
    marketplace.methods.initEvaluator(evaluatorName, evaluatorDomain).call({
        from: window.user
    }).then(console.log)
}

function initFinancer() {
    let financerName = document.getElementById("initializeFinancerName").value

    marketplace.methods.initFinancier(financerName).call({
        from: window.user
    }).then(console.log)
}

function addProduct() {
    let productDescr = $("#addProdDescr")[0].value
    let productDev = Number($("#addProdDevelopCost")[0].value)
    let productRev = Number($("#addProdEvalComp")[0].value)
    let productDomain = $("#addProdDomain")[0].value

    marketplace.methods.addProduct(productDescr, productDev, productRev, productDomain).call({
        from: window.user
    }).then(prodId => {

    }).catch(error => {
        console.log(error)
    })
}

function inactivateProduct() {
    let productNumber = Number($("#inactivateProdId")[0].value)

    marketplace.methods.inactivateProduct(productNumber).call({
        from: window.user
    }).catch(error => {
        console.log(error)
    })
}

function getInactiveProductIds() {
    marketplace.methods.managerShowInactiveProductsId().call({
        from: window.user
    }).then(inactiveProductIds => {
        console.log(inactiveProductIds)
    }).catch(error => {
        console.log(error)
    })
}

function getActiveProductIds() {
    marketplace.methods.managerShowActiveProductsId().call({
        from: window.user
    }).then(activeProductIds => {
        console.log(activeProductIds)
    }).catch(error => {
        console.log(error)
    })
}

function getAllProductIds() {
    marketplace.methods.managerShowAllProductsId().call({
        from: window.user
    }).then(products => {
        console.log(products)
    }).catch(error => {
        console.log(error)
    })
}

function contributeToProduct() {
    let prodId = Number($("#contributeProdId")[0].value)
    let tokenAmount = Number($("#contributeProdTokenAmount")[0].value)

    marketplace.financierContributeToProduct(prodId, tokenAmount).call({
        from: window.user
    }).catch(error => {
        console.log(error)
    })
}
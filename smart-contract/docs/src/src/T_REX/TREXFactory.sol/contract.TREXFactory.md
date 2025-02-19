# TREXFactory
[Git Source](https://github.com/renancorreadev/RWAStation/blob/a342e941dc7ad5be1e9dd1d9d5ed2046f709e55c/src/T_REX/TREXFactory.sol)

**Inherits:**
ITREXFactory, Ownable

*T-REX ERC-3643*

*OpenZeppelin*

*OnchainID*

*T-REX*


## State Variables
### _implementationAuthority
the address of the implementation authority contract used in the tokens deployed by the factory


```solidity
address private _implementationAuthority;
```


### _idFactory
the address of the Identity Factory used to deploy token OIDs


```solidity
address private _idFactory;
```


### tokenDeployed
mapping containing info about the token contracts corresponding to salt already used for CREATE2 deployments


```solidity
mapping(string => address) public tokenDeployed;
```


## Functions
### constructor

constructor is setting the implementation authority and the Identity Factory of the TREX factory


```solidity
constructor(address implementationAuthority_, address idFactory_);
```

### deployTREXSuite

*See [ITREXFactory-deployTREXSuite](/lib/T-REX/contracts/factory/TREXFactory.sol/contract.TREXFactory.md#deploytrexsuite).*


```solidity
function deployTREXSuite(string memory _salt, TokenDetails calldata _tokenDetails, ClaimDetails calldata _claimDetails)
    external
    override
    onlyOwner;
```

### recoverContractOwnership

*See [ITREXFactory-recoverContractOwnership](/lib/T-REX/contracts/factory/TREXFactory.sol/contract.TREXFactory.md#recovercontractownership).*


```solidity
function recoverContractOwnership(address _contract, address _newOwner) external override onlyOwner;
```

### getImplementationAuthority

*See [ITREXFactory-getImplementationAuthority](/lib/T-REX/contracts/proxy/interface/IProxy.sol/interface.IProxy.md#getimplementationauthority).*


```solidity
function getImplementationAuthority() external view override returns (address);
```

### getIdFactory

*See [ITREXFactory-getIdFactory](/lib/T-REX/contracts/factory/TREXFactory.sol/contract.TREXFactory.md#getidfactory).*


```solidity
function getIdFactory() external view override returns (address);
```

### getToken

*See [ITREXFactory-getToken](/lib/T-REX/contracts/factory/TREXFactory.sol/contract.TREXFactory.md#gettoken).*


```solidity
function getToken(string calldata _salt) external view override returns (address);
```

### setImplementationAuthority

*See [ITREXFactory-setImplementationAuthority](/lib/T-REX/contracts/proxy/interface/IProxy.sol/interface.IProxy.md#setimplementationauthority).*


```solidity
function setImplementationAuthority(address implementationAuthority_) public override onlyOwner;
```

### setIdFactory

*See [ITREXFactory-setIdFactory](/lib/T-REX/contracts/factory/TREXFactory.sol/contract.TREXFactory.md#setidfactory).*


```solidity
function setIdFactory(address idFactory_) public override onlyOwner;
```

### _deploy

deploy function with create2 opcode call
returns the address of the contract created


```solidity
function _deploy(string memory salt, bytes memory bytecode) private returns (address);
```

### _deployTIR

function used to deploy a trusted issuers registry using CREATE2


```solidity
function _deployTIR(string memory _salt, address implementationAuthority_) private returns (address);
```

### _deployCTR

function used to deploy a claim topics registry using CREATE2


```solidity
function _deployCTR(string memory _salt, address implementationAuthority_) private returns (address);
```

### _deployMC

function used to deploy modular compliance contract using CREATE2


```solidity
function _deployMC(string memory _salt, address implementationAuthority_) private returns (address);
```

### _deployIRS

function used to deploy an identity registry storage using CREATE2


```solidity
function _deployIRS(string memory _salt, address implementationAuthority_) private returns (address);
```

### _deployIR

function used to deploy an identity registry using CREATE2


```solidity
function _deployIR(
    string memory _salt,
    address implementationAuthority_,
    address _trustedIssuersRegistry,
    address _claimTopicsRegistry,
    address _identityStorage
) private returns (address);
```

### _deployToken

function used to deploy a token using CREATE2


```solidity
function _deployToken(
    string memory _salt,
    address implementationAuthority_,
    address _identityRegistry,
    address _compliance,
    string memory _name,
    string memory _symbol,
    uint8 _decimals,
    address _onchainId
) private returns (address);
```


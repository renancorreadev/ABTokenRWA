# IdentityRegistry
[Git Source](https://github.com/renancorreadev/RWAStation/blob/a342e941dc7ad5be1e9dd1d9d5ed2046f709e55c/src/IdentityRegistry.sol)

**Inherits:**
[IIdentityRegistry](/src/interfaces/IIdentityRegistry.sol/interface.IIdentityRegistry.md), Ownable

*this contract is used to register the identity of the user*

*pt-br: este contrato é usado para registrar a identidade do usuário verificado fazendo a ponte entre o ERC3643 e o IdentityRegistryStorage*

*pt-br: esse contrato gerencia a relação entre os usuários e suas identidades verificadas.*


## State Variables
### identityStorage

```solidity
IIdentityRegistryStorage private identityStorage;
```


## Functions
### constructor


```solidity
constructor(address _identityStorage);
```

### registerIdentity


```solidity
function registerIdentity(address _userAddress, bytes32 _identityHash) external onlyOwner;
```

### removeIdentity


```solidity
function removeIdentity(address _userAddress) external onlyOwner;
```

### isVerified


```solidity
function isVerified(address _userAddress) external view returns (bool);
```

### getIdentity


```solidity
function getIdentity(address _userAddress) external view returns (bytes32);
```


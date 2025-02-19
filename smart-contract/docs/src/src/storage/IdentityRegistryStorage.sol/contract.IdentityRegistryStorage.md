# IdentityRegistryStorage
[Git Source](https://github.com/renancorreadev/RWAStation/blob/a342e941dc7ad5be1e9dd1d9d5ed2046f709e55c/src/storage/IdentityRegistryStorage.sol)

**Inherits:**
[IIdentityRegistryStorage](/src/interfaces/storage/IIdentityRegistryStorage.sol/interface.IIdentityRegistryStorage.md), Ownable

*this contract is used to store the identity of the user*

*pt-br: este contrato é usado para armazenar a identidade do usuário verificado*


## State Variables
### identities

```solidity
mapping(address => bytes32) private identities;
```


## Functions
### onlyValidAddress


```solidity
modifier onlyValidAddress(address _userAddress);
```

### onlyValidIdentity


```solidity
modifier onlyValidIdentity(bytes32 _identityHash);
```

### identityExists


```solidity
modifier identityExists(address _userAddress);
```

### storeIdentity


```solidity
function storeIdentity(address _userAddress, bytes32 _identityHash)
    external
    onlyOwner
    onlyValidAddress(_userAddress)
    onlyValidIdentity(_identityHash);
```

### deleteIdentity


```solidity
function deleteIdentity(address _userAddress) external onlyOwner identityExists(_userAddress);
```

### getIdentityHash


```solidity
function getIdentityHash(address _userAddress) external view returns (bytes32);
```

### exists


```solidity
function exists(address _userAddress) public view returns (bool);
```


# IIdentityRegistryStorage
[Git Source](https://github.com/renancorreadev/RWAStation/blob/a342e941dc7ad5be1e9dd1d9d5ed2046f709e55c/src/interfaces/storage/IIdentityRegistryStorage.sol)

*This interface is used to store the identity of the user*


## Functions
### storeIdentity


```solidity
function storeIdentity(address _userAddress, bytes32 _identityHash) external;
```

### deleteIdentity


```solidity
function deleteIdentity(address _userAddress) external;
```

### getIdentityHash


```solidity
function getIdentityHash(address _userAddress) external view returns (bytes32);
```

### exists


```solidity
function exists(address _userAddress) external view returns (bool);
```

## Events
### IdentityStored

```solidity
event IdentityStored(address indexed userAddress, bytes32 identityHash);
```

### IdentityDeleted

```solidity
event IdentityDeleted(address indexed userAddress);
```


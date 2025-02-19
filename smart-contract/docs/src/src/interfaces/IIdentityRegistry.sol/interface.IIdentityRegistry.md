# IIdentityRegistry
[Git Source](https://github.com/renancorreadev/RWAStation/blob/a342e941dc7ad5be1e9dd1d9d5ed2046f709e55c/src/interfaces/IIdentityRegistry.sol)

*this interface is used to register the identity of the user*


## Functions
### registerIdentity


```solidity
function registerIdentity(address _userAddress, bytes32 _identityHash) external;
```

### removeIdentity


```solidity
function removeIdentity(address _userAddress) external;
```

### isVerified


```solidity
function isVerified(address _userAddress) external view returns (bool);
```

### getIdentity


```solidity
function getIdentity(address _userAddress) external view returns (bytes32);
```

## Events
### IdentityRegistered

```solidity
event IdentityRegistered(address indexed userAddress, bytes32 identityHash);
```

### IdentityRemoved

```solidity
event IdentityRemoved(address indexed userAddress);
```


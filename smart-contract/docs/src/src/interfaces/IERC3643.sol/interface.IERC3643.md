# IERC3643
[Git Source](https://github.com/renancorreadev/RWAStation/blob/a342e941dc7ad5be1e9dd1d9d5ed2046f709e55c/src/interfaces/IERC3643.sol)

**Author:**
Renan C. F. Correa

ERC-3643 pausar, congelar tokens e gerenciar conformidad

*ERC-3643*


## Functions
### setIdentityRegistry


```solidity
function setIdentityRegistry(address _identityRegistry) external;
```

### setCompliance


```solidity
function setCompliance(address _compliance) external;
```

### pause


```solidity
function pause() external;
```

### unpause


```solidity
function unpause() external;
```

### freezeAddress


```solidity
function freezeAddress(address _userAddress, bool _freeze) external;
```

### freezeTokens


```solidity
function freezeTokens(address _userAddress, uint256 _amount) external;
```

### unfreezeTokens


```solidity
function unfreezeTokens(address _userAddress, uint256 _amount) external;
```

## Events
### UpdatedTokenInformation

```solidity
event UpdatedTokenInformation(
    string newName, string newSymbol, uint8 newDecimals, string newVersion, address newOnchainID
);
```

### IdentityRegistryAdded

```solidity
event IdentityRegistryAdded(address indexed identityRegistry);
```

### ComplianceAdded

```solidity
event ComplianceAdded(address indexed compliance);
```

### AddressFrozen

```solidity
event AddressFrozen(address indexed userAddress, bool indexed isFrozen);
```

### TokensFrozen

```solidity
event TokensFrozen(address indexed userAddress, uint256 amount);
```

### TokensUnfrozen

```solidity
event TokensUnfrozen(address indexed userAddress, uint256 amount);
```

### Paused

```solidity
event Paused();
```

### Unpaused

```solidity
event Unpaused();
```


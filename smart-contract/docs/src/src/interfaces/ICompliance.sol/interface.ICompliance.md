# ICompliance
[Git Source](https://github.com/renancorreadev/RWAStation/blob/a342e941dc7ad5be1e9dd1d9d5ed2046f709e55c/src/interfaces/ICompliance.sol)

*this interface is used to add compliance rules and check if the user is compliant*

*pt-br: esse contrato é usado para adicionar regras de compliance e verificar se o usuário é compliant*


## Functions
### addRule


```solidity
function addRule(bytes32 ruleHash) external;
```

### removeRule


```solidity
function removeRule(bytes32 ruleHash) external;
```

### isTransferAllowed


```solidity
function isTransferAllowed(address from, address to, uint256 amount) external view returns (bool);
```

## Events
### RuleAdded

```solidity
event RuleAdded(bytes32 ruleHash);
```

### RuleRemoved

```solidity
event RuleRemoved(bytes32 ruleHash);
```

### TransferValidated

```solidity
event TransferValidated(address indexed from, address indexed to, uint256 amount);
```


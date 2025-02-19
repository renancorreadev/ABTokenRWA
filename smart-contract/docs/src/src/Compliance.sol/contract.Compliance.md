# Compliance
[Git Source](https://github.com/renancorreadev/RWAStation/blob/a342e941dc7ad5be1e9dd1d9d5ed2046f709e55c/src/Compliance.sol)

**Inherits:**
[ICompliance](/src/interfaces/ICompliance.sol/interface.ICompliance.md), Ownable

*pt-br: esse contrato é usado para adicionar regras de compliance e verificar se o usuário é compliant*


## State Variables
### complianceRules

```solidity
mapping(bytes32 => bool) private complianceRules;
```


## Functions
### onlyValidRule


```solidity
modifier onlyValidRule(bytes32 ruleHash);
```

### addRule


```solidity
function addRule(bytes32 ruleHash) external onlyOwner onlyValidRule(ruleHash);
```

### removeRule


```solidity
function removeRule(bytes32 ruleHash) external onlyOwner onlyValidRule(ruleHash);
```

### isTransferAllowed


```solidity
function isTransferAllowed(address from, address to, uint256 amount) external view override returns (bool);
```


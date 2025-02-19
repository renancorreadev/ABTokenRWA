# ABToken
[Git Source](https://github.com/renancorreadev/RWAStation/blob/a342e941dc7ad5be1e9dd1d9d5ed2046f709e55c/src/ABToken.sol)

**Inherits:**
ERC20, Ownable, [IERC3643](/src/interfaces/IERC3643.sol/interface.IERC3643.md)


## State Variables
### identityRegistry

```solidity
IIdentityRegistry public identityRegistry;
```


### compliance

```solidity
ICompliance public compliance;
```


### paused

```solidity
bool public paused;
```


### frozenAddresses

```solidity
mapping(address => bool) public frozenAddresses;
```


### frozenTokens

```solidity
mapping(address => uint256) public frozenTokens;
```


## Functions
### constructor


```solidity
constructor(string memory name, string memory symbol, address _identityRegistry, address _compliance)
    ERC20(name, symbol);
```

### notPaused


```solidity
modifier notPaused();
```

### notFrozen


```solidity
modifier notFrozen(address user);
```

### setIdentityRegistry


```solidity
function setIdentityRegistry(address _identityRegistry) external onlyOwner;
```

### setCompliance


```solidity
function setCompliance(address _compliance) external onlyOwner;
```

### pause


```solidity
function pause() external onlyOwner;
```

### unpause


```solidity
function unpause() external onlyOwner;
```

### freezeAddress


```solidity
function freezeAddress(address _userAddress, bool _freeze) external onlyOwner;
```

### freezeTokens


```solidity
function freezeTokens(address _userAddress, uint256 _amount) external onlyOwner;
```

### unfreezeTokens


```solidity
function unfreezeTokens(address _userAddress, uint256 _amount) external onlyOwner;
```

### _beforeTokenTransfer


```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount) internal override notPaused notFrozen(from);
```


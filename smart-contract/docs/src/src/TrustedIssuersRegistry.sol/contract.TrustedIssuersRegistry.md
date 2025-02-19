# TrustedIssuersRegistry
[Git Source](https://github.com/renancorreadev/RWAStation/blob/a342e941dc7ad5be1e9dd1d9d5ed2046f709e55c/src/TrustedIssuersRegistry.sol)

**Inherits:**
[ITrustedIssuersRegistry](/src/interfaces/ITrustedIssuersRegistry.sol/interface.ITrustedIssuersRegistry.md), Ownable


## State Variables
### trustedIssuers

```solidity
address[] private trustedIssuers;
```


### isTrustedIssuer

```solidity
mapping(address => bool) private isTrustedIssuer;
```


## Functions
### addTrustedIssuer


```solidity
function addTrustedIssuer(address _issuer) external onlyOwner;
```

### removeTrustedIssuer


```solidity
function removeTrustedIssuer(address _issuer) external onlyOwner;
```

### getTrustedIssuers


```solidity
function getTrustedIssuers() external view returns (address[] memory);
```

### verifyIsTrustedIssuer


```solidity
function verifyIsTrustedIssuer(address _issuer) external view returns (bool);
```

## Errors
### IssuerAlreadyExists

```solidity
error IssuerAlreadyExists(address issuer);
```

### IssuerDoesNotExist

```solidity
error IssuerDoesNotExist(address issuer);
```


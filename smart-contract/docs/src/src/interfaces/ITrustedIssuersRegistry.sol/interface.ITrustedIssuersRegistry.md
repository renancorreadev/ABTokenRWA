# ITrustedIssuersRegistry
[Git Source](https://github.com/renancorreadev/RWAStation/blob/a342e941dc7ad5be1e9dd1d9d5ed2046f709e55c/src/interfaces/ITrustedIssuersRegistry.sol)

*this interface is used to register the trusted issuers*


## Functions
### addTrustedIssuer


```solidity
function addTrustedIssuer(address _issuer) external;
```

### removeTrustedIssuer


```solidity
function removeTrustedIssuer(address _issuer) external;
```

### verifyIsTrustedIssuer


```solidity
function verifyIsTrustedIssuer(address _issuer) external view returns (bool);
```

## Events
### TrustedIssuerAdded

```solidity
event TrustedIssuerAdded(address indexed issuer);
```

### TrustedIssuerRemoved

```solidity
event TrustedIssuerRemoved(address indexed issuer);
```


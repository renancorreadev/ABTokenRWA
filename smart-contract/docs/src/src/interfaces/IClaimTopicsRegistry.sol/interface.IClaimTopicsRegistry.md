# IClaimTopicsRegistry
[Git Source](https://github.com/renancorreadev/RWAStation/blob/a342e941dc7ad5be1e9dd1d9d5ed2046f709e55c/src/interfaces/IClaimTopicsRegistry.sol)


## Functions
### addClaimTopic


```solidity
function addClaimTopic(uint256 _claimTopic) external;
```

### removeClaimTopic


```solidity
function removeClaimTopic(uint256 _claimTopic) external;
```

### getClaimTopics


```solidity
function getClaimTopics() external view returns (uint256[] memory);
```

## Events
### ClaimTopicAdded

```solidity
event ClaimTopicAdded(uint256 indexed claimTopic);
```

### ClaimTopicRemoved

```solidity
event ClaimTopicRemoved(uint256 indexed claimTopic);
```


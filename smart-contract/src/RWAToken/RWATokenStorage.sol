// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IModularCompliance} from "@erc3643/contracts/compliance/modular/IModularCompliance.sol";
import {IIdentityRegistry} from "@erc3643/contracts/registry/interface/IIdentityRegistry.sol";

contract RWATokenStorage {
    /// @dev ERC20 basic variables
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    uint256 internal _totalSupply;

    /// @dev Token information
    string internal _tokenName;
    string internal _tokenSymbol;
    uint8 internal _tokenDecimals;
    address internal _tokenOnchainID;
    string internal constant _TOKEN_VERSION = "4.1.3";

    /// @dev Variables of freeze and pause functions
    mapping(address => bool) internal _frozen;
    mapping(address => uint256) internal _frozenTokens;

    bool internal _tokenPaused = false;

    /// @dev Identity Registry contract used by the onchain validator system
    IIdentityRegistry internal _tokenIdentityRegistry;

    /// @dev Compliance contract linked to the onchain validator system
    IModularCompliance internal _tokenCompliance;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     */
    uint256[49] private __gap;
}

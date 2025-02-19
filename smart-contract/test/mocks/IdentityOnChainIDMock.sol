// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Identity} from "@onchain-id/solidity/contracts/Identity.sol";

contract MockIdentityOnChainID is Identity {
    constructor() Identity(msg.sender, false) {}
}

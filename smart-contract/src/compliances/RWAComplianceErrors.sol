// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

error NotApprovedBuyer(address buyer);
error InvalidBuyerData(address buyer, string reason);
error NotBoundCompliance(address compliance);
error IncomeTooLow(address buyer, uint256 required, uint256 provided);
error ComplianceCheckFailed(
    address from,
    address to,
    uint256 value,
    string reason
);
error ComplianceAlreadyBound(address compliance);
error UnauthorizedCaller();

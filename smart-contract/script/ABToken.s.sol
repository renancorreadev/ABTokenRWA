// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";

contract DeployABToken is Script {
    address public deployer;

    function run() external {
        deployer = vm.envAddress("DEPLOYER_KEY");

        vm.startBroadcast(deployer);

     
        vm.stopBroadcast();
    }
}

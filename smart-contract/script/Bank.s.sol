// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Bank} from "../src/bank.sol";
import "forge-std/console.sol";

contract BankScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        Bank bank = new Bank("INDIANCURRENCY", "inr", 2, 0);
        vm.stopBroadcast();

        console.log("Deployed Bank Contract at address:", address(bank));
    }
}
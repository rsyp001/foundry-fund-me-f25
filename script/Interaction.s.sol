// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_MONEY = 0.01 ether;

    function fundFundMe(address mostRecentDeployed) public {
        FundMe(payable(mostRecentDeployed)).fund{value: SEND_MONEY}();
        console.log("funded amount is %s", SEND_MONEY);
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();

        fundFundMe(mostRecentDeployed);
        vm.stopBroadcast();
    }
}

contract WithDrawFundMe is Script {
    function WithdrawFundMe(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        WithdrawFundMe(mostRecentDeployed);
    }
}

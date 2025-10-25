// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8;
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address PriceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEThConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEThConfig();
        }
    }

    function getSepoliaEThConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory SepoliaConfig = NetworkConfig({PriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return SepoliaConfig;
    }

    function getOrCreateAnvilEThConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.PriceFeed != address(0)) {}

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({PriceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }
}

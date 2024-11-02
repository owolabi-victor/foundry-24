// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

/// @title HelperConfig
/// @notice Deploys mock contracts on local networks and grabs existing addresses on live networks.
contract HelperConfig is Script {
    /// @dev Structure to hold the price feed address based on network configuration
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH / USD price feed address
    }

    /// @notice Sets the active network configuration based on the chain ID.
    constructor() {
        // If on Sepolia network
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        }
        else if (block.chainid == 1) {
          activeNetworkConfig = getmainnetEthConfig();
         } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    } // Close constructor

    /// @notice Returns Sepolia network configuration with the appropriate price feed address.
    /// @return NetworkConfig struct with the Sepolia price feed address.
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getmainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }

    /// @notice Returns Anvil network configuration with the appropriate price feed address.
    /// @return NetworkConfig struct with the Anvil price feed address.
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
      if (activeNetworkConfig.priceFeed != address(0)) {
        return activeNetworkConfig;
      }
      // price feed address

      // 1.  Deploy mocks when we are on a local anvil chain
      // 2. return the mock address

      vm.startBroadcast();
      MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
      vm.stopBroadcast();

      NetworkConfig memory anvilConfig = NetworkConfig({
        priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}

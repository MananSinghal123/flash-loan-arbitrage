// SPDX-License-Identifier: UNLICENSEDs
pragma solidity ^0.8.10;

import {Script, console} from "forge-std/Script.sol";
import {TradeExecutor} from "../src/TradeExecutor.sol";
import {ArbitrageExecutor} from "../src/ArbitrageExecutor.sol";
import {ArbitrageFinder} from "../src/ArbitrageFinder.sol";
import {ArbitrageBot} from "../src/ArbitrageBot.sol";

contract Deploy is Script {
    // Define the addresses for external contracts/routers
    address constant AAVE_POOL_ADDRESS_PROVIDER =
        address(0x012bAC54348C0E635dCAc9D5FB99f06F24136C9A); // Replace with actual address
    address constant UNISWAP_V3_QUOTER =
        address(0x0b343475d44EC2b4b8243EBF81dc888BF0A14b36); // Replace with actual address
    address constant UNISWAP_V3_SWAP_ROUTER =
        address(0x0b343475d44EC2b4b8243EBF81dc888BF0A14b36); // Replace with actual address
    address constant VELO_ROUTER =
        address(0x3c8B650257cFb5f272f799F5e2b4e65093a11a05); // Replace with actual address

    function run()
        public
        returns (
            TradeExecutor tradeExecutor,
            ArbitrageExecutor arbitrageExecutor,
            ArbitrageFinder arbitrageFinder,
            ArbitrageBot arbitrageBot
        )
    {
        // Start the broadcast to deploy with the msg.sender
        vm.startBroadcast();

        // Deploy TradeExecutor
        tradeExecutor = new TradeExecutor(UNISWAP_V3_SWAP_ROUTER, VELO_ROUTER);
        console.log("TradeExecutor deployed to:", address(tradeExecutor));

        // Deploy ArbitrageExecutor
        arbitrageExecutor = new ArbitrageExecutor(
            AAVE_POOL_ADDRESS_PROVIDER,
            address(tradeExecutor)
        );
        console.log(
            "ArbitrageExecutor deployed to:",
            address(arbitrageExecutor)
        );

        // Deploy ArbitrageFinder
        arbitrageFinder = new ArbitrageFinder(
            UNISWAP_V3_QUOTER,
            UNISWAP_V3_SWAP_ROUTER,
            VELO_ROUTER
        );
        console.log("ArbitrageFinder deployed to:", address(arbitrageFinder));

        // Deploy ArbitrageBot
        arbitrageBot = new ArbitrageBot(
            address(arbitrageFinder),
            address(arbitrageExecutor)
        );
        console.log("ArbitrageBot deployed to:", address(arbitrageBot));

        // Whitelist dependencies
        arbitrageExecutor.addToWhitelist(address(arbitrageBot));
        arbitrageFinder.addToWhitelist(address(arbitrageBot));
        tradeExecutor.addToWhitelist(address(arbitrageExecutor));

        vm.stopBroadcast();
    }
}

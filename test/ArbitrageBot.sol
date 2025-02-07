// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ArbitrageBot.sol";
import "../src/ArbitrageFinder.sol";

contract ArbitrageTest is Test {
    address constant USDC = 0x7F5c764cBc14f9669B88837ca1490cCa17c31607;
    address constant WETH = 0x4200000000000000000000000000000000000006;

    ArbitrageBot public bot;
    ArbitrageFinder public finder;
    address public owner;

    event ArbitrageOpportunity(bool indexed isFound);

    function setUp() public {
        owner = makeAddr("owner");
        vm.startPrank(owner);

        bot = ArbitrageBot(0x926C8f3C05DD3Afe91CbE313b3d215de2Be0a38e);
        finder = ArbitrageFinder(0x3E19A77892b05882e1431360B164261522B4aBc9);

        // Fork mainnet state
        vm.createSelectFork(vm.envString("RPC_URL"));

        vm.stopPrank();
    }

    function testArbitrageSystem() public {
        vm.startPrank(owner);

        // First test the finder
        (bool isFound, Arbitrage.Opportunity memory opportunity) = finder.find(
            WETH,
            USDC
        );

        // Then test the bot
        vm.expectEmit(true, false, false, false);
        emit ArbitrageOpportunity(isFound);

        bot.execute(WETH, USDC);

        vm.stopPrank();
    }

    function testArbitrageWithDifferentTokens() public {
        vm.startPrank(owner);

        (bool isFound, ) = finder.find(USDC, WETH);

        vm.expectEmit(true, false, false, false);
        emit ArbitrageOpportunity(isFound);

        bot.execute(USDC, WETH);

        vm.stopPrank();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ArbitrageFinder.sol";

contract ArbitrageFinderTest is Test {
    ArbitrageFinder public finder;
    address constant USDC = 0x7F5c764cBc14f9669B88837ca1490cCa17c31607;
    address constant WETH = 0x4200000000000000000000000000000000000006;
    address owner;

    // Mock contracts
    MockQuoter public quoter;
    MockVeloRouter public veloRouter;

    function setUp() public {
        owner = makeAddr("owner");
        vm.startPrank(owner);

        // Deploy mock contracts
        quoter = new MockQuoter();
        veloRouter = new MockVeloRouter();

        // Deploy ArbitrageFinder with mock addresses
        finder = new ArbitrageFinder(
            address(quoter),
            address(0x1234), // Mock Uniswap router address
            address(veloRouter)
        );

        vm.stopPrank();
    }

    function testFindArbitrageOpportunity() public {
        vm.startPrank(owner);

        // Setup mock responses
        quoter.setQuoteResponse(2 ether); // Uniswap price
        veloRouter.setReserves(1 ether, 1.5 ether); // Velo price = 1.5

        (bool isFound, Arbitrage.Opportunity memory opportunity) = finder.find(
            WETH,
            USDC
        );

        assertTrue(isFound, "Should find arbitrage opportunity");
        assertEq(
            opportunity.firstTransaction.tokenFrom,
            WETH,
            "Incorrect first token"
        );
        assertEq(
            opportunity.firstTransaction.tokenTo,
            USDC,
            "Incorrect second token"
        );
        assertEq(
            opportunity.firstTransaction.exchange,
            address(veloRouter),
            "Incorrect first exchange"
        );

        vm.stopPrank();
    }

    function testNoArbitrageOpportunity() public {
        vm.startPrank(owner);

        // Setup mock responses with similar prices
        quoter.setQuoteResponse(1 ether);
        veloRouter.setReserves(1 ether, 1.01 ether);

        (bool isFound, Arbitrage.Opportunity memory opportunity) = finder.find(
            WETH,
            USDC
        );

        assertFalse(isFound, "Should not find arbitrage opportunity");
        assertEq(
            opportunity.firstTransaction.tokenFrom,
            address(0),
            "Should return zero address"
        );

        vm.stopPrank();
    }
}

// Mock contracts
contract MockQuoter {
    uint256 private quoteResponse;

    function setQuoteResponse(uint256 _response) external {
        quoteResponse = _response;
    }

    function quoteExactInputSingle(
        address,
        address,
        uint24,
        uint256,
        uint160
    ) external view returns (uint256) {
        return quoteResponse;
    }
}

contract MockVeloRouter {
    uint256 private reserve0;
    uint256 private reserve1;

    function setReserves(uint256 _reserve0, uint256 _reserve1) external {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function getReserves(
        address,
        address,
        bool
    ) external view returns (uint256, uint256) {
        return (reserve0, reserve1);
    }
}

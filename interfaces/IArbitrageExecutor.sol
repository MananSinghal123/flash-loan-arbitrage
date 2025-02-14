// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Arbitrage.sol";

interface IArbitrageExecutor {
    function execute(Arbitrage.Opportunity memory arbitrage) external;
}

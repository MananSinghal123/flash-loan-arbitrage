// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/ITradeExecutor.sol";
import "../interfaces/IArbitrageExecutor.sol";
import "./Whitelisted.sol";
import "./Arbitrage.sol";
import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

contract ArbitrageExecutor is IArbitrageExecutor {
    address payable public owner;
    ITradeExecutor private immutable tradeExecutor;

    constructor(address executorAddress) {
        owner = payable(msg.sender);
        tradeExecutor = ITradeExecutor(executorAddress);
    }

    function execute(Arbitrage.Opportunity memory arbitrage) external {
        // Transfer tokens from owner to contract
        IERC20(arbitrage.firstTransaction.tokenFrom).transferFrom(
            owner,
            address(this),
            arbitrage.firstTransaction.amount
        );

        // Approve trade executor to spend tokens
        IERC20(arbitrage.firstTransaction.tokenFrom).approve(
            address(tradeExecutor),
            arbitrage.firstTransaction.amount
        );

        // Execute first trade
        uint256 amountPurchased = tradeExecutor.executeTrade(
            arbitrage.firstTransaction.exchange,
            arbitrage.firstTransaction.tokenFrom,
            arbitrage.firstTransaction.tokenTo,
            arbitrage.firstTransaction.amount
        );

        // Approve trade executor to spend tokens from the first swap
        IERC20(arbitrage.secondTransaction.tokenFrom).approve(
            address(tradeExecutor),
            amountPurchased
        );

        // Execute second trade
        tradeExecutor.executeTrade(
            arbitrage.secondTransaction.exchange,
            arbitrage.secondTransaction.tokenFrom,
            arbitrage.secondTransaction.tokenTo,
            amountPurchased
        );
    }

    receive() external payable {}
}

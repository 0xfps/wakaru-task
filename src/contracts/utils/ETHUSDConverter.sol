// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

import {AggregatorV3Interface}
from "chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

abstract contract ETHUSDConverter {
    /// Sepolia ETH -> USD.
    AggregatorV3Interface internal ETH_USD =
        AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);

    /**
    * @dev Returns the amount of ETH that equals $20.
    * @return uint256 Amount of ETH that equals $20.
    */
    function twentyUSDInETH() public view returns (uint256) {
        (, int price, , , ) = ETH_USD.latestRoundData();
        if (price < 0) revert("Wakaru: BELOW_ZERO");

        uint256 ethFor20USD = (20e8 * 1e18) / uint256(price);
        uint256 pointZeroOneEthFor20USD = (1e6 * 1e18) / uint256(price);

        return ethFor20USD + pointZeroOneEthFor20USD;
    }
}
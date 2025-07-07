// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBNBPrice {

    function averageBnbToUsd() external view returns (uint);
    function averageUsdToBnb() external view returns (uint);
}
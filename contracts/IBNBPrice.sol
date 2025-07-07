// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPriceChecker {

    function bep20Token_uSD() external view returns (uint);
}
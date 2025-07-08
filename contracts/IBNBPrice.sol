// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBNBPrice {
     
    function setEqMode() external; 
    function getEqMode() external view returns( bool);
    function getEqModeString() external view returns( string memory);
    function getAverage() external payable returns (uint256 ,bool);
    function bnbToUsd(uint8 index) external view  returns (uint);
    function usdToBnb(uint8 index) external view  returns (uint);
}
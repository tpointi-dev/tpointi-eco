// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBNBPrice {
     
    function setEqMode() external; 
    function getEqMode() external view returns( bool);
    function getEqModeString() external view returns( string memory);
    function viewAverage() external view returns (uint256);
    function viewAverageStatic() external view returns (uint256);
    function bnbToUsd(uint8 index) external view  returns (uint);
    function usdToBnb(uint8 index) external view  returns (uint);
}
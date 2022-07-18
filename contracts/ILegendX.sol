// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface ILegendX {
    function transferOwnership(address newOwner) external;
    function devMint(address[] memory addresses, uint256[] memory numMints) external;
}
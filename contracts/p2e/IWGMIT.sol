// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IWGMITycoon is IERC1155 {

    function setTycoonCost(
        uint256[] calldata ids, 
        uint256[] calldata burnAmount, 
        uint256[] calldata moonzCost
    ) external;

    function setTycoonMaxSupply(uint256[] calldata ids, uint256[] calldata supply) external;

}
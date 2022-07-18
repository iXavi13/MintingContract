// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITycoon {
    struct Tycoon {
        uint64 multiplierLevel;
        uint64 capacityLevel;
        uint128 lastClaim;
        uint256 balance;
    }

    struct MultiplierCost {
        uint128 maxLevel;
        uint128 cost;
    }

    struct CapIncreaseCost {
        uint128 maxLevel;
        uint128 cost;
    }

    event TycoonInitialized(
        address indexed owner,
        uint256 multiplierLevel,
        uint256 capacityLevel,
        uint256 lastClaim,
        uint256 balance
    );

    event TycoonConfigured(
        uint256 indexed tycoonId
    );

    event YieldSet(
        uint256 indexed tycoonId,
        uint256 yield
    );

    event MultiplierSet(
        uint256 indexed tycoonId,
        uint256 indexed maxLevel,
        uint256 cost,
        uint256 multiplier
    );

    event CapacitySet(
        uint256 indexed tycoonId,
        uint256 indexed level,
        uint256 cost,
        uint256 capacity
    );
}
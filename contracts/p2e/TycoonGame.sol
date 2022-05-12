// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ITycoon.sol";
import "./IMoonz.sol";
import "./IWGMIT.sol";


//TODO LIST
// BEFORE TRANSFER SET TYCOONS
// ON MINT SET TYCOONS
// PRIORITY - ERC1155 TO TYCOON YIELD
// PAUSE, INITIALIZE GAME AND REINITIALIZE FUNCTION

contract TycoonGame is ITycoon, AccessControl, ReentrancyGuard {
    bytes32 public constant GAME_ADMIN = keccak256("GAME_ADMIN");
    IWGMITycoon public tycoonInterface;
    IMoonz public moonz;

    constructor(address admin) {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(GAME_ADMIN, admin);
    }
     
    // Yield Info
    uint256 public yieldStartTime = 1643670000; // 2021-01-31_18-00_EST
    bool paused = true;
    
    //Player => Tycoon ID => Tycoon Info
    mapping(address => mapping (uint256 => Tycoon)) public tycoons;

    //Tycoon ID => Value
    mapping(uint256 => uint256) public yield;

    //Tycoon ID => Level => Multiplier/Cap
    mapping(uint256 => mapping (uint256 => uint256)) public capacity;
    mapping(uint256 => mapping (uint256 => uint256)) public multiplier;

    //Tycoon ID => Level => Cost
    mapping(uint256 => mapping (uint256 => MultiplierCost)) public multiplierCost;
    mapping(uint256 => mapping (uint256 => CapIncreaseCost)) public capIncreaseCost;

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    function stakeTycoon(uint256 id, uint256 amount) external callerIsUser() {
        require(yield[id] > 0, "Nonexistent token URI");

        tycoonInterface.safeTransferFrom(msg.sender, address(this), id, amount, "");
        if(tycoons[msg.sender][id].balance == 0){
            _initializeTycoon(id);
        }
        else{
            tycoons[msg.sender][id].balance = tycoonInterface.balanceOf(msg.sender, id);
        }
    }

    function claim(uint256[] calldata ids) external callerIsUser() {
        require(ids.length > 0, "Claiming 0 amount");
        uint256 claimAmount = 0;

        for (uint256 i = 0; i < ids.length;) {
            claimAmount += _getPendingYield(ids[i], msg.sender);
            unchecked { ++i; }
        }

        moonz.mint(msg.sender, claimAmount);
    }

    function increaseCapsAndMultipliers(
        uint256[] calldata multiplierIds, 
        uint256[] calldata capacityIds) 
        external 
        callerIsUser() 
    {
        increaseCaps(capacityIds);
        increaseMultipliers(multiplierIds);
    }

    function increaseCaps(uint256[] calldata ids) public callerIsUser() {
        require(ids.length > 0, "No tycoon selected");

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 capLevel_ = uint256(tycoons[msg.sender][ids[i]].capacityLevel);

            require(capIncreaseCost[ids[i]][capLevel_].maxLevel > 0, "Cap level doesn't exist");
            require(capLevel_ < capIncreaseCost[ids[i]][capLevel_].maxLevel + 1, "Max cap reached");
            require(moonz.balanceOf(msg.sender) >= capIncreaseCost[ids[i]][capLevel_].cost, "Not enough moonz");
            require(moonz.allowance(msg.sender, address(this)) >= capIncreaseCost[ids[i]][capLevel_].cost, "Moonz allowance too low"); //potentially move out by setting a high value
            
            moonz.burnFrom(msg.sender, capIncreaseCost[ids[i]][capLevel_].cost);
            unchecked {
                tycoons[msg.sender][ids[i]].capacityLevel += 1;
            }
        }
    }

    function increaseMultipliers(uint256[] calldata ids) public callerIsUser() {
        require(ids.length > 0, "No tycoon selected");
    
        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 multiplierLevel_ = uint256(tycoons[msg.sender][ids[i]].multiplierLevel);

            require(multiplierCost[ids[i]][multiplierLevel_].maxLevel > 0, "Cap level doesn't exist");
            require(multiplierLevel_ < multiplierCost[ids[i]][multiplierLevel_].maxLevel + 1, "Max cap reached");
            require(moonz.balanceOf(msg.sender) >= multiplierCost[ids[i]][multiplierLevel_].cost, "Not enough moonz");
            require(moonz.allowance(msg.sender, address(this)) >= multiplierCost[ids[i]][multiplierLevel_].cost, "Not enough moonz allowance"); //potentially unneeded
            
            moonz.burnFrom(msg.sender, multiplierCost[ids[i]][multiplierLevel_].cost);
            tycoons[msg.sender][ids[i]].multiplierLevel = uint32(multiplierLevel_);
        }
    }

    function _getPendingYield(uint256 id, address owner) internal returns(uint256){
        Tycoon memory tycoon_ = tycoons[owner][id];
        if (tycoon_.lastClaim == 0 || tycoon_.lastClaim < yieldStartTime) return 0;

        uint256 capacityValue = capacity[id][tycoon_.capacityLevel];
        uint256 multiplierValue = multiplier[id][tycoon_.multiplierLevel];
        tycoons[owner][id].lastClaim = uint64(block.timestamp);

        //Checking if started every single time, check this logic again
        uint256 _timeElapsed = tycoon_.lastClaim > yieldStartTime ? block.timestamp - tycoon_.lastClaim : block.timestamp - yieldStartTime;
        return ((_timeElapsed * yield[id]) / 1 days) * ((tycoon_.balance * multiplierValue) * 1 ether)
                > ((capacityValue * tycoon_.balance) * 1 ether)
                ? ((capacityValue * tycoon_.balance) * 1 ether)
                : ((_timeElapsed * yield[id]) / 1 days) * ((tycoon_.balance * multiplierValue) * 1 ether);
    }

    
    function _initializeTycoon(uint256 id) internal {
        tycoons[msg.sender][id] = Tycoon(
            1,
            1,
            uint128(block.timestamp),
            tycoonInterface.balanceOf(msg.sender, id)
        );
    }

    //ADMIN FUNCTIONS
    function configureTycoon(
        uint256[] calldata ids, 
        uint256[] calldata yields_,
        uint256[] calldata tycoonCost_,
        uint256[] calldata tycoonBurnAmount_,
        uint256[] calldata tycoonSupply_
        ) external onlyRole(GAME_ADMIN) {
        require(
            ids.length == yields_.length 
            && ids.length == tycoonCost_.length 
            && ids.length == tycoonSupply_.length, 
            "Incorrect Array Lengths"
        );

        tycoonInterface.setTycoonCost(ids, tycoonBurnAmount_, tycoonCost_);
        tycoonInterface.setTycoonMaxSupply(ids, tycoonSupply_);
        _setYields(ids,yields_);
    }

    function configureMultiplierLevels(
        uint256[] calldata ids, 
        uint256[] calldata levels,
        uint256[] calldata multiplier_,
        uint256[] calldata cost,
        uint256[] calldata maxLevel
        ) external onlyRole(GAME_ADMIN) {
        require(ids.length == levels.length && ids.length == cost.length, "Incorrect Array Lengths");

        for (uint256 i = 0; i < ids.length;) {
            require(maxLevel[ids[i]] > 0, "Incorrect max level");

            uint256 multiplierValue = multiplier_[ids[i]];
            multiplierCost[ids[i]][levels[ids[i]]].cost = uint128(cost[ids[i]]);
            multiplierCost[ids[i]][levels[ids[i]]].maxLevel = uint128(maxLevel[ids[i]]);
            multiplier[ids[i]][levels[ids[i]]] = multiplierValue;

            emit MultiplierSet(ids[i], levels[ids[i]],cost[ids[i]], multiplierValue);
            unchecked { ++i; }
        }

    }

    function configureCapacityLevels(
        uint256[] calldata ids, 
        uint256[] calldata levels,
        uint256[] calldata cost,
        uint256[] calldata maxLevel,
        uint256[] calldata capacity_
        ) external onlyRole(GAME_ADMIN) {
        require(ids.length == levels.length && ids.length == cost.length, "Incorrect Array Lengths");

        for (uint256 i = 0; i < ids.length;) {
            require(maxLevel[ids[i]] > 0, "Incorrect max level");

            uint256 capacityValue = capacity_[ids[i]];
            capIncreaseCost[ids[i]][levels[ids[i]]].cost = uint128(cost[ids[i]]);
            capIncreaseCost[ids[i]][levels[ids[i]]].maxLevel = uint128(maxLevel[ids[i]]);
            capacity[ids[i]][levels[ids[i]]] = capacity_[ids[i]];

            emit CapacitySet(ids[i], levels[ids[i]],cost[ids[i]], capacityValue);
            unchecked { ++i; }
        }

    }

    function _setYields(uint256[] calldata ids, uint256[] calldata yieldRates) internal onlyRole(GAME_ADMIN) {
        require(ids.length == yieldRates.length, "Incorrect array lengths!");

        for (uint256 i = 0; i < ids.length; ++i) {
            yield[ids[i]] = yieldRates[ids[i]];
            emit YieldSet(ids[i], yieldRates[ids[i]]);
        }
    }

    function setBalance(address owner, uint256[] calldata ids) external onlyRole(GAME_ADMIN) {
        require(ids.length > 0, "Incorrect array length");

        for (uint256 i = 0; i < ids.length; ++i) {
            tycoons[owner][ids[i]].balance = tycoonInterface.balanceOf(owner, ids[i]);
        }
    }

    function setMoonzInterface(IMoonz IMoonz_) external onlyRole(GAME_ADMIN) {
        moonz = IMoonz_;
    }

    function withdrawMoney() external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}
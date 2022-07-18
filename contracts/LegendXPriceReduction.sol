// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ILegendX.sol";

contract LegendXPriceReduction is Ownable, PaymentSplitter {
    ILegendX LegendX;
    
    constructor(ILegendX LegendXInterface) PaymentSplitter(_splitterAddressList, _shareList) {
        LegendX = LegendXInterface;
    }

    address[] private _splitterAddressList = [
        0x492EFaAE6bd47AC479DA908f91ff6f15Bc395371,
        0x3E7B68c3896b45808A0dA50B48Cb2A44D11342EF, 
        0x342b68aDe2384aE1e61A65758d2Af49138dB5224,
        0x4Cc1bF50E741Cc7e5A152bB9e5b9D5071cE9f402
    ];

    uint256[] private _shareList = [10, 15, 15, 60];

    uint256 price = 0.044 ether;
    uint256 maxTxn = 4;
    bool paused = true;

    function mint(uint256 mintAmount)
        public
        payable
    {
        require(!paused, "Mint paused");
        require(mintAmount > 0, "Mint Amount Incorrect");
        require(msg.value >= price * mintAmount, "Incorrect payment amount!");
        require(mintAmount < maxTxn + 1, "Mint Amount Incorrect");
        address[] memory sender = new address[](1); uint256[] memory mints = new uint[](1);
        sender[0] = msg.sender; mints[0] = mintAmount;

        LegendX.devMint(sender, mints);
    }

    function airdrop(address[] memory addresses, uint256[] memory numMints) external onlyOwner {
        LegendX.devMint(addresses, numMints);
    }

    function transferLegendXOwner(address newOwner) external onlyOwner {
        LegendX.transferOwnership(newOwner);
    }

    function setInterface(ILegendX LegendXInterface) external onlyOwner {
        LegendX = LegendXInterface;
    }

    function setPrice(uint256 newPrice) external onlyOwner {
        price = newPrice;
    }

    function setPaused(bool paused_) external onlyOwner {
        paused = paused_;
    }

    function setMaxTxn(uint256 maxTxn_) external onlyOwner {
        maxTxn = maxTxn_;
    }
}
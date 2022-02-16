// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Rosie is Ownable, ERC721A, ReentrancyGuard {
    constructor() ERC721A("Rosie", "ROSIE") {}

    struct SaleConfig {
        uint8  maxTxn;
        uint16 collectionSize;
        uint16 devSupply;
        uint32 allowlistSaleStartTime;
        uint32 allowlistSaleEndTime;
        uint32 publicSaleStartTime;
        uint64 allowlistPrice;
        uint64 publicPrice;
    }

    SaleConfig public saleConfig = SaleConfig(
        5,
        100,
        10,
        1644113479,
        2527693879,
        1644113479,
        0.05 ether,
        0.05 ether
    );

    mapping(address => uint256) public allowlist;

    modifier isPublicOpen
    {
        require(block.timestamp >= uint256(saleConfig.publicSaleStartTime));
        _;
    }

    modifier isAllowlistOpen
    {
        require(block.timestamp >= uint256(saleConfig.allowlistSaleStartTime) && block.timestamp <= uint256(saleConfig.allowlistSaleEndTime), "Allowlist is closed!");
        _;
    }


    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    function publicSaleMint(uint256 mintAmount)
        external
        payable
        callerIsUser
        isPublicOpen
    {
        uint256 price = uint256(saleConfig.publicPrice);
        uint256 collectionSize = uint256(saleConfig.collectionSize);
        uint256 maxTxn = uint256(saleConfig.maxTxn);
        require(mintAmount >= 1 && mintAmount <= maxTxn, "Incorrect mint quantity!");
        require(totalSupply() + mintAmount <= collectionSize, "reached max supply");
        require(msg.value >= price * mintAmount && mintAmount >= 1, "Input values incorrect!");

        _safeMint(msg.sender, mintAmount);
    }

    function allowlistMint(uint8 mintAmount) 
        external 
        payable 
        callerIsUser 
        isAllowlistOpen
    {
        uint256 price = uint256(saleConfig.allowlistPrice);
        uint256 collectionSize = uint256(saleConfig.collectionSize);
        require(allowlist[msg.sender] > 0, "not eligible for allowlist mint");
        require(mintAmount <= allowlist[msg.sender], "Exceeded max mint amount!");
        require(totalSupply() + mintAmount <= collectionSize, "reached max supply");
        require(mintAmount >= 1, "Mint Amount Incorrect");
        require(msg.value >= price * mintAmount && mintAmount >= 1, "Input values incorrect!");
        allowlist[msg.sender] = allowlist[msg.sender] - mintAmount;
        _safeMint(msg.sender, mintAmount);
    }

    function seedAllowlist(address[] memory addresses, uint256[] memory numSlots)
        external
        onlyOwner
    {
        require( addresses.length == numSlots.length, "addresses does not match numSlots length" );
        for (uint256 i = 0; i < addresses.length; i++) {
            allowlist[addresses[i]] = numSlots[i];
        }
    }

    // // metadata URI
    string private _baseTokenURI;

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function withdrawMoney() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }

    function getOwnershipData(uint256 tokenId)
        external
        view
        returns (TokenOwnership memory)
    {
        return ownershipOf(tokenId);
    }

}
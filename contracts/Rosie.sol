// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ERC721A.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Rosie is Ownable, ERC721A, ReentrancyGuard {
    constructor() ERC721A("Rosie", "ROSIE") {}

    struct SaleConfig {
        uint16 maxTxn;
        uint16 collectionSize;
        uint32 allowlistSaleStartTime;
        uint32 allowlistSaleEndTime;
        uint32 publicSaleStartTime;
        uint64 allowlistPrice;
        uint64 publicPrice;
    }

    SaleConfig public saleConfig = SaleConfig(
        10,
        10000,
        1644113479,
        2527693879,
        1644113479,
        0.05 ether,
        0.05 ether
    );

    bytes32 public merkleRoot = 0x0b6e25a995ad97c378eb717afb66025c9b97b8b64727cc38277af800b89efc67;
    mapping(address => uint256) public allowlistClaimed;

    modifier isPublicOpen
    {
        require(block.timestamp > uint256(saleConfig.publicSaleStartTime));
        _;
    }

    modifier isAllowlistOpen
    {
        require(block.timestamp > uint256(saleConfig.allowlistSaleStartTime) && block.timestamp < uint256(saleConfig.allowlistSaleEndTime), "Allowlist is closed!");
        _;
    }


    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    function publicSaleMint(uint256 mintAmount)
        public
        payable
        callerIsUser
        isPublicOpen
    {
        uint256 price = uint256(saleConfig.publicPrice);
        uint256 collectionSize = uint256(saleConfig.collectionSize);
        uint256 maxTxn = uint256(saleConfig.maxTxn);
        require(mintAmount > 0 && mintAmount < maxTxn + 1, "Incorrect mint quantity!");
        require(totalSupply() + mintAmount <= collectionSize, "reached max supply");
        require(msg.value >= price * mintAmount, "Input values incorrect!");

        _safeMint(msg.sender, mintAmount);
    }

    function allowlistMint(uint8 mintAmount, bytes32[] calldata _merkleProof) 
        external 
        payable 
        callerIsUser 
        isAllowlistOpen
    {
        uint256 price = uint256(saleConfig.allowlistPrice);
        uint256 collectionSize = uint256(saleConfig.collectionSize);
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Proof not on allowlist!");
        require(totalSupply() + mintAmount <= collectionSize, "reached max supply");
        require(mintAmount > 0, "Mint Amount Incorrect");
        require(msg.value >= price * mintAmount, "Input values incorrect!");
        //set claimed somehow
        _safeMint(msg.sender, mintAmount);
    }

    function airdropMint(address[] memory addresses, uint256[] memory numMints)
        external
        onlyOwner
    {
        require(addresses.length == numMints.length, "Sizes dont match");
        for (uint i = 0; i < addresses.length; i++) {
            _safeMint(addresses[i], numMints[i]);
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
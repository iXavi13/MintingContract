// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC721A.sol";

//  ______     ______     ______     ______     ______   ______   
// /\  == \   /\  ___\   /\  __ \   /\  ___\   /\__  _\ /\  ___\  
// \ \  __<   \ \  __\   \ \  __ \  \ \___  \  \/_/\ \/ \ \___  \ 
//  \ \_____\  \ \_____\  \ \_\ \_\  \/\_____\    \ \_\  \/\_____\
//   \/_____/   \/_____/   \/_/\/_/   \/_____/     \/_/   \/_____/
//Developed by RosieX - @RosieX_eth

contract BEASTS is Ownable, ERC721A {
    constructor() ERC721A("BEASTS", "BEASTS") {}

    struct SaleConfig {
        uint128 collectionSize;
        uint32 allowlistStartTime;
        uint32 allowlistEndTime;
        uint32 publicStartTime;
        uint32 publicEndTime;
    }

    struct PurchaseConfig {
        uint128 maxBalance;
        uint128 price;
    }

    SaleConfig public saleConfig = SaleConfig(
        333,
        1658235600,
        1658257200,
        0,
        0
    );

    PurchaseConfig public purchaseConfig = PurchaseConfig(
        1,
        0.05 ether
    );


    string private _baseTokenURI = "";
    bool public isPaused = false;

    bytes32 public allowlistMerkleRoot;
    mapping(address => bool) public allowlistClaimed;
    mapping(address => bool) public publicClaimed;

    modifier isAllowlistOpen
    {
        require(block.timestamp > uint256(saleConfig.allowlistStartTime) && block.timestamp < uint256(saleConfig.allowlistEndTime), "Allowlist window is closed!");
        _;
    }

    modifier isPublicOpen
    {
        require(block.timestamp > uint256(saleConfig.publicStartTime) && block.timestamp < uint256(saleConfig.publicEndTime), "Public window is closed!");
        _;
    }


    modifier callerIsUser 
    {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    modifier isValidMint(uint256 mintAmount) 
    {
        uint256 price = uint256(purchaseConfig.price);
        uint256 collectionSize = uint256(saleConfig.collectionSize);
        require(mintAmount > 0, "Mint Amount Incorrect");
        require(msg.value >= price * mintAmount, "Incorrect payment amount!");
        require(totalSupply() + mintAmount < collectionSize + 1, "Reached max supply");
        require(!isPaused, "Mint paused");
        _;
    }

    // PUBLIC AND EXTERNAL FUNCTIONS
    function publicSaleMint(uint256 mintAmount)
        external
        payable
        callerIsUser
        isPublicOpen
        isValidMint(mintAmount)
    {
        
        uint256 maxBalance = uint256(purchaseConfig.maxBalance);
        require(mintAmount < maxBalance + 1, "Mint Amount Incorrect");
        require(!publicClaimed[msg.sender], "Exceeds max mint amount!");
        
        publicClaimed[msg.sender] = true;
        _safeMint(msg.sender, mintAmount);
    }

    function allowlistMint(uint256 mintAmount, bytes32[] calldata _merkleProof) 
        external 
        payable 
        callerIsUser 
        isAllowlistOpen
        isValidMint(mintAmount)
    {
        uint256 maxBalance = uint256(purchaseConfig.maxBalance);
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, allowlistMerkleRoot, leaf), "Proof not on allowlist!");
        require(mintAmount < maxBalance + 1, "Mint Amount Incorrect");
        require(!allowlistClaimed[msg.sender], "Exceeds max mint amount!");

        allowlistClaimed[msg.sender] = true;
        _safeMint(msg.sender, mintAmount);
    }

    // VIEW FUNCTIONS
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    // ADMIN FUNCTIONS
    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function airdrop(address[] memory addresses, uint256[] memory numMints)
        external
        onlyOwner
    {
        uint256 collectionSize = uint256(saleConfig.collectionSize);
        require(addresses.length == numMints.length, "Arrays dont match");

        for (uint i = 0; i < addresses.length; i++) {
            require(totalSupply() + numMints[i] < collectionSize + 1, "Reached max supply");
            require(numMints[i] > 0, "Cannot mint 0!");

            _safeMint(addresses[i], numMints[i]);
        }
    }

    function setAllowlistMerkleRoot(bytes32 root) external onlyOwner {
        allowlistMerkleRoot = root;
    }

    //NOTE: price must be in ethers (value * 10**18)
    function setPrice(uint64 price) external onlyOwner {
        purchaseConfig.price = price;
    }

    function setMaxSupply(uint128 size) external onlyOwner {
        saleConfig.collectionSize = size;
    }

    function setPaused(bool paused) external onlyOwner {
        isPaused = paused;
    }

    function setAllowlistSaleTime(uint32 startTimestamp, uint32 endTimestamp) external onlyOwner {
        saleConfig.allowlistStartTime = startTimestamp;
        saleConfig.allowlistEndTime = endTimestamp;
    }

    function setPublicSaleTime(uint32 startTimestamp, uint32 endTimestamp) external onlyOwner {
        saleConfig.publicStartTime = startTimestamp;
        saleConfig.publicEndTime = endTimestamp;
    }

    function withdrawMoney() external onlyOwner {
        require(address(this).balance > 0);
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}
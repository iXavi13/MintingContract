// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC721A-old.sol";

//    _/        _/_/_/_/    _/_/_/  _/_/_/_/  _/      _/  _/_/_/    _/      _/
//   _/        _/        _/        _/        _/_/    _/  _/    _/    _/  _/   
//  _/        _/_/_/    _/  _/_/  _/_/_/    _/  _/  _/  _/    _/      _/      
// _/        _/        _/    _/  _/        _/    _/_/  _/    _/    _/  _/     
//_/_/_/_/  _/_/_/_/    _/_/_/  _/_/_/_/  _/      _/  _/_/_/    _/      _/ 
//Developed by RosieX - @RosieX_eth

contract LegendXOld is Ownable, ERC721A, ReentrancyGuard, PaymentSplitter {
    constructor() ERC721A("Legend-X", "LEGENDX") PaymentSplitter(_splitterAddressList, _shareList) {}

    struct SaleConfig {
        uint16 collectionSize;
        uint16 claimSize;
        uint32 allowlistStartTime;
        uint32 allowlistEndTime;
        uint32 prePublicStartTime;
        uint32 prePublicEndTime;
        uint32 publicStartTime;
        uint32 claimlistStartTime;
        uint32 claimlistEndTime;
    }

    struct PurchaseConfig {
        uint64 maxTxn;
        uint64 allowlistMaxBalance;
        uint64 publicMaxBalance;
        uint64 price;
    }

    SaleConfig public saleConfig = SaleConfig(
        10000,
        4200,
        1650060000,
        1650103200,
        1650103200,
        1650146400,
        1650362400,
        1650189600,
        1650362400
    );

    PurchaseConfig public purchaseConfig = PurchaseConfig(
        4,
        2,
        8,
        0.1 ether
    );

    address[] private _splitterAddressList = [
        0x693065F2e132E9A8B70AA4D43120EAef7f8f2685, 
        0x8627912B6ec8bD7A204Ea46026E11efBB290df3b, 
        0xdf1fa21aaD71C50E642FcA3Aa4332da17BbEA409, 
        0x0F8aAC3F77668f6053cFF816713EE891F8B4B161 
    ];

    uint256[] private _shareList = [25, 25, 25, 25];


    string private _baseTokenURI;
    bool public isPaused = true;

    bytes32 public allowlistMerkleRoot = 0x0b6e25a995ad97c378eb717afb66025c9b97b8b64727cc38277af800b89efc67;
    mapping(address => uint256) public allowlistBalance;

    bytes32 public prePublicMerkleRoot = 0x0b6e25a995ad97c378eb717afb66025c9b97b8b64727cc38277af800b89efc67;
    mapping(address => uint256) public prePublicBalance;

    bytes32 public claimlistMerkleRoot = 0x5901829e5cbb7ab8996ca63c4d81d35dc2f09b8d28fbf1075e895bd737f82178;
    mapping(address => bool) public claimlistClaimed;

    modifier isAllowlistOpen
    {
        require(block.timestamp > uint256(saleConfig.allowlistStartTime) && block.timestamp < uint256(saleConfig.allowlistEndTime), "Window is closed!");
        _;
    }

    modifier isPrePublicOpen
    {
        require(block.timestamp > uint256(saleConfig.prePublicStartTime) && block.timestamp < uint256(saleConfig.prePublicEndTime), "Window is closed!");
        _;
    }

    modifier isClaimOpen
    {
        require(block.timestamp > uint256(saleConfig.claimlistStartTime) && block.timestamp < uint256(saleConfig.claimlistEndTime), "Window is closed!");
        _;
    }

    modifier isPublicOpen
    {
        require(block.timestamp > uint256(saleConfig.publicStartTime), "Window is closed!");
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
        uint256 maxTxn = uint256(purchaseConfig.maxTxn);
        uint256 collectionSize = uint256(saleConfig.collectionSize);
        require(mintAmount > 0 && mintAmount < maxTxn + 1, "Mint Amount Incorrect");
        require(msg.value >= price * mintAmount, "Incorrect payment amount!");
        require(totalSupply() + mintAmount < collectionSize + 1, "Reached max supply");
        require(!isPaused, "Mint paused");
        _;
    }

    // PUBLIC AND EXTERNAL FUNCTIONS

    function publicSaleMint(uint256 mintAmount)
        public
        payable
        callerIsUser
        isPublicOpen
        isValidMint(mintAmount)
    {
        _safeMint(msg.sender, mintAmount);
    }

    function prePublicSaleMint(uint256 mintAmount, bytes32[] calldata _merkleProof)
        public
        payable
        callerIsUser
        isPrePublicOpen
        isValidMint(mintAmount)
    {
        uint256 publicMaxBalance = uint256(purchaseConfig.publicMaxBalance);
        uint256 collectionSize = uint256(saleConfig.collectionSize);
        uint256 claimSize = uint256(saleConfig.claimSize);
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, prePublicMerkleRoot, leaf), "Proof not on allowlist!");
        require(totalSupply() + mintAmount < collectionSize - claimSize + 1, "Reached max public capacity");
        require(prePublicBalance[msg.sender] + mintAmount < publicMaxBalance + 1, "Exceeds max mint amount!");

        prePublicBalance[msg.sender] += mintAmount;
        _safeMint(msg.sender, mintAmount);
    }

    function allowlistMint(uint256 mintAmount, bytes32[] calldata _merkleProof) 
        external 
        payable 
        callerIsUser 
        isAllowlistOpen
        isValidMint(mintAmount)
    {
        uint256 allowlistMaxBalance = uint256(purchaseConfig.allowlistMaxBalance);
        uint256 collectionSize = uint256(saleConfig.collectionSize);
        uint256 claimSize = uint256(saleConfig.claimSize);
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, allowlistMerkleRoot, leaf), "Proof not on allowlist!");
        require(totalSupply() + mintAmount < collectionSize - claimSize + 1, "Reached max allowlist capacity");
        require(allowlistBalance[msg.sender] + mintAmount < allowlistMaxBalance + 1, "Exceeds max mint amount!");

        allowlistBalance[msg.sender] += mintAmount;
        _safeMint(msg.sender, mintAmount);
    }

    function claimMint(uint256 allowance, bytes32[] calldata _merkleProof) 
        external 
        payable 
        callerIsUser 
        isClaimOpen
    {
        uint256 collectionSize = uint256(saleConfig.collectionSize);
        bytes32 leaf = keccak256(abi.encode(msg.sender,Strings.toString(allowance)));
        require(MerkleProof.verify(_merkleProof, claimlistMerkleRoot, leaf), "Proof not on allowlist!");
        require(totalSupply() + allowance < collectionSize + 1, "Reached max supply");
        require(!claimlistClaimed[msg.sender], "Already claimed!");
        require(!isPaused, "Mint paused");
        claimlistClaimed[msg.sender] = true;

        _safeMint(msg.sender, allowance);
    }

    // VIEW FUNCTIONS

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

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    // ADMIN FUNCTIONS

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function airdropMint(address[] memory addresses, uint256[] memory numMints)
        external
        onlyOwner
    {
        require(addresses.length == numMints.length, "Arrays dont match");
        for (uint i = 0; i < addresses.length; i++) {
            require(numMints[i] > 0, "Cannot mint 0!");
            _safeMint(addresses[i], numMints[i]);
        }
    }

    function setAllowlistMerkleRoot(bytes32 root) external onlyOwner {
        allowlistMerkleRoot = root;
    }

    function setPrePublicMerkleRoot(bytes32 root) external onlyOwner {
        prePublicMerkleRoot = root;
    }

    function setClaimlistMerkleRoot(bytes32 root) external onlyOwner {
        claimlistMerkleRoot = root;
    }

    function setMaxSupply(uint16 size) external onlyOwner {
        saleConfig.collectionSize = size;
    }

    function setPaused(bool paused) external onlyOwner {
        isPaused = paused;
    }

    function setAllowlistSaleTime(uint32 startTimestamp, uint32 endTimestamp) external onlyOwner {
        saleConfig.allowlistStartTime = startTimestamp;
        saleConfig.allowlistEndTime = endTimestamp;
    }

    function setPrePublicSaleTime(uint32 startTimestamp, uint32 endTimestamp) external onlyOwner {
        saleConfig.prePublicStartTime = startTimestamp;
        saleConfig.prePublicEndTime = endTimestamp;
    }

    function setClaimlistSaleTime(uint32 startTimestamp, uint32 endTimestamp) external onlyOwner {
        saleConfig.claimlistStartTime = startTimestamp;
        saleConfig.claimlistEndTime = endTimestamp;
    }

    function setPublicSaleTime(uint32 startTimestamp) external onlyOwner {
        saleConfig.publicStartTime = startTimestamp;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC721A.sol";

contract AIZUKI is Ownable, ERC721A {
    string private _baseTokenURI;

    constructor() ERC721A("Aizuki", "AIZUKI") {}

    uint256 price = .0069 ether;
    uint256 collectionSize = 3333;
    
    //CONSTANTS
    uint256 MAX_TXN = 10;
    uint256 MAX_MINT = 20;
    uint256 FREE_AMOUNT = 1000;

    //STATE
    bool isLive = false;
    mapping(address => uint256) public amountMinted;

    function mint(uint256 mintAmount)
        public
        payable
    {
        uint256 totalSupply_ = totalSupply();
        require(isLive, "Mint not open!");
        require(mintAmount > 0, "Mint Amount Incorrect");
        require(totalSupply_ + mintAmount < collectionSize + 1, "Reached max supply");
        require(mintAmount + amountMinted[msg.sender] < MAX_MINT + 1, "Exceeds per wallet amount");
        require(mintAmount < MAX_TXN + 1, "Exceeds max per txn");

        //FREE MINTS -> PARTIAL -> PAID
        if(totalSupply_ + mintAmount < FREE_AMOUNT + 1){
        }
        else if(totalSupply_ < FREE_AMOUNT && totalSupply_ + mintAmount > FREE_AMOUNT){
            require(msg.value >= ((totalSupply_ + mintAmount) - FREE_AMOUNT) * price);
        }
        else{
            require(msg.value >= mintAmount * price, "ETH amount incorrect");
        }

        amountMinted[msg.sender] += mintAmount;
        _safeMint(msg.sender, mintAmount);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    //ADMIN
    function setPrice(uint price_) external onlyOwner {
        price = price_ * 1 ether;
    }

    function setCollectionSize(uint colSize) external onlyOwner{
        collectionSize = colSize;
    }

    function devMint(address to, uint256 mintAmount) external onlyOwner {
        _safeMint(to, mintAmount);
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function setMintState(bool active) external onlyOwner{
        isLive = active;
    }

    function withdrawMoney() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ERC721A.sol";

contract MoonBats is Ownable, ERC721A, ReentrancyGuard {
    constructor() ERC721A("MoonBats", "MOONBATS") {}

    uint256 PRICE = .01 ether;
    uint256 MAX_TXN = 10;

    string private _baseTokenURI;

    function mint(uint256 mintAmount)
        public
        payable
    {
        
        require(mintAmount > 0, "Mint Amount Incorrect");
        require(msg.value > mintAmount * PRICE, "Pay amount Incorrect");
        require(mintAmount < MAX_TXN + 1, "Exceeds per transaction amount");
        _safeMint(msg.sender, mintAmount);
    }

    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }

    function getOwnershipData(uint256 tokenId) external view returns (TokenOwnership memory)
    {
        return ownershipOf(tokenId);
    }

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

}
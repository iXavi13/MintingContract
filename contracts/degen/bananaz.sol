// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC721A.sol";

contract BananaLandz is Ownable, ERC721A, PaymentSplitter {
    string private _baseTokenURI;

    constructor() ERC721A("BananaLandz", "BANANALANDZ") PaymentSplitter(_splitterAddressList, _shareList) {}

    //CONSTANTS
    uint256 PRICE = .00420 ether;
    uint256 MAX_TXN = 5;
    uint256 MAX_MINT = 20;
    uint256 COLLECTION_SIZE = 3333;
    uint256 FREE_AMOUNT = 700;

    //STATE
    bool isLive = false;
    mapping(address => uint256) public amountMinted;

    //PAYMENT
    address[] private _splitterAddressList = [
        0x755698050f8DE8d77F2924062119cee2f82ADA86,
        0x0370448FE7E1A8724e05c574760a4ec84Af67211,
        0x9cE2591D44f5fE9159e6CC772E65DFfA570Cdd30,
        0x670343130f750Fd0a07fa2eF003D056A9A8a3145,
        0x8DB842F23fda4AAFb96427d224B7353737E3e7bF
    ];
    uint256[] private _shareList = [20,20,20,20,20];

    function mint(uint256 mintAmount)
        public
        payable
    {
        uint256 totalSupply_ = totalSupply();
        require(isLive, "Mint not open!");
        require(mintAmount > 0, "Mint Amount Incorrect");
        require(totalSupply_ + mintAmount < COLLECTION_SIZE + 1, "Reached max supply");
        require(mintAmount + amountMinted[msg.sender] < MAX_MINT + 1, "Exceeds per wallet amount");
        require(mintAmount < MAX_TXN + 1, "Exceeds max per txn");

        //FREE MINTS -> PARTIAL -> PAID
        if(totalSupply_ + mintAmount < FREE_AMOUNT + 1){
        }
        else if(totalSupply_ < FREE_AMOUNT && totalSupply_ + mintAmount > FREE_AMOUNT){
            require(msg.value >= ((totalSupply_ + mintAmount) - FREE_AMOUNT) * PRICE);
        }
        else{
            require(msg.value >= mintAmount * PRICE, "ETH amount incorrect");
        }

        amountMinted[msg.sender] += mintAmount;
        _safeMint(msg.sender, mintAmount);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    //ADMIN
    function devMint(address to, uint256 mintAmount) external onlyOwner {
        _safeMint(to, mintAmount);
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function setMintState(bool active) external onlyOwner{
        isLive = active;
    }
}
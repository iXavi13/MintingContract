// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import '@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol';

//Mystery Shells by Cyber Turtles
//Developed by Rosie - @RosieX_eth

contract MysteryShells is ERC1155, ERC1155Supply, ERC1155Burnable, Ownable, ReentrancyGuard {
    string public name_;
    string public symbol_; 
    string public metadataURI_;

    constructor(string memory _name, string memory _symbol, string memory _uri) ERC1155(_uri) {
        name_ = _name;
        symbol_ = _symbol;
        metadataURI_ = _uri;
    } 

    uint256 public publicStartTime = 1652317200;
    uint256 public publicEndTime = 1652403600;
    uint256 public mShellPrice = 0.02 ether;
    bool public paused = true;

    modifier isOpen
    {
        require(block.timestamp > publicStartTime && block.timestamp < publicEndTime, "Mint window is closed!");
        _;
    }

    function mintShell(uint256 amount) external payable isOpen() {
        require(!paused, "Mint is paused");
        require(amount > 0 && amount < 11, "Mint amount incorrect");
        require(msg.value >= amount * mShellPrice, "Incorrect ETH amount");

        _mint(msg.sender, 0, amount, "");
    }

    //VIEWS
    function uri(uint256 _id) public view override returns (string memory) {
            require(totalSupply(_id) > 0, "URI: nonexistent token");
            
            return string(abi.encodePacked(metadataURI_,Strings.toString(_id)));
    } 

    function name() public view returns (string memory) {
        return name_;
    }

    function symbol() public view returns (string memory) {
        return symbol_;
    }  

    //ADMIN FUNCTIONS
    function setBaseURI(string memory baseURI) external onlyOwner{
        metadataURI_ = baseURI;
    }

    function setPrice(uint256 price) external onlyOwner {
        mShellPrice = price * 1 ether;
    }

    function setPaused(bool paused_) external onlyOwner{
        paused = paused_;
    }

    function setSaleTime(uint256 start, uint256 end) external onlyOwner{
        publicStartTime = start;
        publicEndTime = end;
    }
    
    function mint(address account, uint256 id, uint256 amount) external onlyOwner {
        _mint(account, id, amount, "");
    }   

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external onlyOwner {
        _mintBatch(to,ids,amounts,data);
    }

    function withdrawMoney() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    //OVERRIDES
    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual override{
        super._mint(account, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._mintBatch(to, ids, amounts, data);
    }

    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal virtual override{
        super._burn(account, id, amount);
    }

    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual override {
        super._burnBatch(account, ids, amounts);
    }  

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }  

    function supportsInterface(bytes4 interfaceId) 
        public 
        view 
        virtual 
        override
        (ERC1155) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

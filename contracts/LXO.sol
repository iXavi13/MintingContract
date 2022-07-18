// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import '@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol';
import '@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol';

contract LegendXOrigins is ERC1155, ERC1155Supply, ERC1155Burnable, Ownable {
    string public name_;
    string public symbol_; 
    string public metadataURI_;

    constructor( string memory _name, string memory _symbol, string memory _uri) ERC1155(_uri) {
        name_ = _name;
        symbol_ = _symbol;
        metadataURI_ = _uri;
    }     

    function mint(address account, uint256 id, uint256 amount) external onlyOwner {
        _mint(account, id, amount, "");
    }   

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external onlyOwner {
        _mintBatch(to,ids,amounts,data);
    }

    function airdropBatch(address[] memory accounts, uint256 id, uint256 amount) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _mint(accounts[i], id, amount, "");
        }
    }

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

    function setOwner(address _addr) public onlyOwner {
        transferOwnership(_addr);
    }

    function setURI(string memory baseURI) external onlyOwner {
        metadataURI_ = baseURI;
        _setURI(baseURI);
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

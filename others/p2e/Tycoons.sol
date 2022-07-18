// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "./IMoonz.sol";
import "./ITycoonGame.sol";

contract WGMITycoons is ERC1155, AccessControl, ERC1155Supply, ERC1155Burnable, Ownable {
    string public name_;
    string public symbol_; 
    string public metadataURI_;
    ITycoonGame public game;
    IMoonz public moonz;

    struct TycoonCost {
        uint128 burnAmount;
        uint128 moonzCost;
    }

    constructor( 
        string memory _name, 
        string memory _symbol, 
        string memory _uri,
        ITycoonGame _game,
        IMoonz _moonz
        ) 
        ERC1155(_uri) 
    {
        name_ = _name;
        symbol_ = _symbol;
        metadataURI_ = _uri;
        game = _game;
        moonz = _moonz;
    }


    uint256 public TYCOON_PRICE = 0.00 ether; //Change to price
    uint256 public MAX_PAYABLE_SUPPLY = 10000;

    uint256 initialDegenSupply = 0;
    bool public paused = true;

    mapping(uint256 => TycoonCost) public tycoonCost;
    mapping(uint256 => uint256) public maxTycoonSupply;

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    modifier isNotPaused() {
        require(!paused, "The game is paused");
        _;
    }

    function mintDegen(uint256 mintAmount) external payable callerIsUser() isNotPaused() {
        require(mintAmount > 0, "Incorrect mint amount");
        require(msg.value >= TYCOON_PRICE * mintAmount, "Incorrect ETH Amount");
        require(initialDegenSupply + mintAmount < MAX_PAYABLE_SUPPLY + 1, "Exceeded payable supply");

        initialDegenSupply += mintAmount;
        _mint(msg.sender, 1, mintAmount, "");
    }

    function mintTycoon(uint256 id, uint256 mintAmount) external isNotPaused() {
        require(mintAmount > 0, "Incorrect mint amount");
        require(moonz.allowance(msg.sender, address(this)) > tycoonCost[id].moonzCost * 1 ether);

        _mintTycoons(id, mintAmount);
    }

    function batchMintTycoons(
        uint256[] memory ids, 
        uint256[] memory mintAmounts) 
        external payable 
        isNotPaused(){
        //problem if split values, can oveerflow mint. need to keep track of supplies
        for (uint256 i = 0; i < ids.length; i++) {
            require(mintAmounts[i] > 0, "Incorrect mint amount");
            require(ids[i] > 0, "");
            
            _mintTycoons(ids[i], mintAmounts[i]);
        }
    }

    function _mintTycoons(uint256 id, uint256 mintAmount) internal {
        require(tycoonCost[id].moonzCost > 0, "Tycoon not configured");

        moonz.burnFrom(msg.sender, tycoonCost[id].moonzCost * 1 ether);
        if (id != 1)
            burn(msg.sender, id - 1, tycoonCost[id].burnAmount * mintAmount);
        _mint(msg.sender, id, mintAmount, "");
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
    function setPaused(bool paused_) external onlyOwner {
        paused = paused_;
    }

    function setTycoonCost(uint256[] calldata ids, uint256[] calldata burnAmount, uint256[] calldata moonzCost) external onlyOwner {
        require(ids.length == burnAmount.length && burnAmount.length == moonzCost.length, "Incorrect array lengths");
        for (uint256 i = 0; i < ids.length; i++) {
            tycoonCost[ids[i]] = TycoonCost(
                uint128(burnAmount[ids[i]]),
                uint128(moonzCost[ids[i]])
            );
        }
    }

    function setTycoonMaxSupply(uint256[] calldata ids, uint256[] calldata supply) external onlyOwner {
        require(ids.length == supply.length, "Incorrect array lengths");
        for (uint256 i = 0; i < ids.length; i++) {
            maxTycoonSupply[ids[i]] = supply[ids[i]];
        }
    }


    function mint(address account, uint256 id, uint256 amount) external onlyOwner {
        _mint(account, id, amount, "");
    }   

    function mintBatch(
        address to, 
        uint256[] memory ids, 
        uint256[] memory amounts, 
        bytes memory data) external onlyOwner {
        _mintBatch(to,ids,amounts,data);
    }

    //Overrides
    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual override {
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
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) 
        public 
        view 
        virtual 
        override
        (ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
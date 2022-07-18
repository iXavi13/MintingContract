// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./ERC721A-old.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BaseRosie is Ownable, ERC721A, ReentrancyGuard {
    constructor() ERC721A("Rosie", "ROSIE") {}
    

    function publicSaleMint(uint256 mintAmount)
        external
    {
        _safeMint(msg.sender, mintAmount);
    }

    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }


}

// //    function seedAllowlist(address[] memory addresses, uint256[] memory numSlots)
//         public
//         onlyOwner
//     {
//         require( addresses.length == numSlots.length, "addresses does not match numSlots length" );
//         for (uint256 i = 0; i < addresses.length; i++) {
//             allowlist[addresses[i]] = numSlots[i];
//         }
//     }
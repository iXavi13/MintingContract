pragma solidity ^0.8.4;

import '../ERC721A.sol';
import '../Rosie.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


// contract ERC721AGasReporterMock is ERC721A {
//     constructor(string memory name_, string memory symbol_) ERC721A(name_, symbol_) {}

//     function safeMintOne(address to) public {
//         _safeMint(to, 1);
//     }

//     function mintOne(address to) public {
//         _mint(to, 1, '', false);
//     }

//     function safeMintTen(address to) public {
//         _safeMint(to, 10);
//     }

//     function mintTen(address to) public {
//         _mint(to, 10, '', false);
//     }
// }

contract RosieMock is Rosie{
    constructor() Rosie() {}

    function newNumberMinted(address owner) public {
        numberMinted(owner);
    }

    function mint1First()
        public
        payable
    {
        publicSaleMint(1);
    }

    function mint1Public()
        public
        payable
    {
        publicSaleMint(1);
    }

    function mint3Public()
        public
        payable
    {
        publicSaleMint(3);
    }

    function mint5Public()
        public
        payable
    {
        publicSaleMint(5);
    }

    function mintTenPublic()
        public
        payable
    {
        publicSaleMint(10);
    }
}
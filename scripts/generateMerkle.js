const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

let allowlistAddresses = [
    "0x693065F2e132E9A8B70AA4D43120EAef7f8f2685",
    "0x693065F2e132E9A8B70AA4D43120EAef7f8f2686",
    "0x693065F2e132E9A8B70AA4D43120EAef7f8f2687",
    "0x693065F2e132E9A8B70AA4D43120EAef7f8f2688",
    "0x693065F2e132E9A8B70AA4D43120EAef7f8f2689",
];

const leafNodes = allowlistAddresses.map( address => keccak256(address));
const merkleTree = new MerkleTree(leafNodes, keccak256, {sortPairs: true});
const rootHash = merkleTree.getRoot();

console.log("Root Hash: " + rootHash.toString('hex'));
console.log("Our tree:\n" + merkleTree.toString());

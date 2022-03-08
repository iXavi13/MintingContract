const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

let allowlistAddresses = [
    "0x693065F2e132E9A8B70AA4D43120EAef7f8f2685",
    "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",
    "0x693065F2e132E9A8B70AA4D43120EAef7f8f2687",
    "0x693065F2e132E9A8B70AA4D43120EAef7f8f2688",
    "0x693065F2e132E9A8B70AA4D43120EAef7f8f2689",
];

const leafNodes = allowlistAddresses.map( address => keccak256(address));
const merkleTree = new MerkleTree(leafNodes, keccak256, {sortPairs: true});
const rootHash = merkleTree.getRoot();

const claimingAddress = keccak256("0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC");
console.log("Root Hash: " + rootHash.toString('hex'));
console.log("Our tree:\n" + merkleTree.toString());
console.log("Proof: ", merkleTree.getHexProof(claimingAddress))
console.log(merkleTree.verify(merkleTree.getHexProof(claimingAddress),claimingAddress, rootHash.toString('hex')))

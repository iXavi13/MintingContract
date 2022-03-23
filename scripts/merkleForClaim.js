const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');
const ethers = require('ethers')

let allowlistAddresses = {
    "0x693065F2e132E9A8B70AA4D43120EAef7f8f2685": "2",
    "0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc": "3"
};

function initialHash(mintingAddress, allowance){
    return ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(['address', 'string'], [mintingAddress, allowance]))
}

const leafNodes = Object.entries(allowlistAddresses).map( address => initialHash(...address));
const merkleTree = new MerkleTree(leafNodes, keccak256, {sortPairs: true});
const rootHash = merkleTree.getRoot();

const claimingAddress = initialHash("0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc","3");

console.log("Encoded data: ", ethers.utils.defaultAbiCoder.encode(['address', 'string'], ["0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc", "3"]))
console.log("Leaf: ", ethers.utils.keccak256("0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC", "3"))
console.log("Leaf encoded: ", ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(['address', 'string'], ["0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC", "3"])))
//0x186242da37f63bfed1ad9722674976528124340e9031b336401122665e905a28
//0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc33
// console.log(ethers.utils.parseBytes32String(0x5158f37949c453b9c2477b6cabbf6eefaff55b698dbb595cb054e8e306b72e99))
//console.log(ethers.utils.defaultAbiCoder.decode(["address", "uint256"], ethers.utils.hexDataSlice("0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc32",2)))
console.log(claimingAddress)
console.log("Root Hash: " + rootHash.toString('hex'));
console.log("Our tree:\n" + merkleTree.toString());
console.log("Proof: ", merkleTree.getHexProof(claimingAddress))
console.log(merkleTree.verify(merkleTree.getHexProof(claimingAddress),claimingAddress, rootHash.toString('hex')))
console.log(merkleTree.getHexProof(claimingAddress))

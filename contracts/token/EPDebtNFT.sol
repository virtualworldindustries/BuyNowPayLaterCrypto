// SPDX-License-Identifier: MIT
pragma solidity 0.5.15;

import "../../../decentracraft-contracts/contracts/Decentracraft.sol";


contract EPDebtNFT is Decentracraft {

    struct NFTInfo{
        uint256 gnome;
        string  name;
        uint    breedCount;
        uint256 lastBreedTime;
        uint256 parent1ID;
        uint256 parent2ID;
    }

    mapping (uint256 => NFTInfo) public nftInfo;

    address public crafter;

    constructor() public {
        name = "EtherPay Debt NFT";
        symbol = "EPDBT";
        contracturi = "https://nft-image-service.herokuapp.com/strain.json";
        tokenbaseuri = "https://nft-image-service.herokuapp.com/";
    }

    function setCrafter(address _crafter) public ownerOnly {
        crafter = _crafter;
    }

    function setName(uint256 _id, string memory _name) public {
        require(msg.sender == nfOwners[_id] || msg.sender == crafter);
        nftInfo[_id].name = _name;
    }

    function getName(uint256 _id) public view returns(string memory){
        return nftInfo[_id].name;
    }

    function setGnome(uint256 _id, uint256 _gnome) public {
        require(msg.sender == crafter);
        nftInfo[_id].gnome = _gnome;
    }
    
    function getGnome(uint256 _id) public view returns(uint256){
        return nftInfo[_id].gnome;
    }

    function setBreedCount(uint256 _id, uint _breedCount) public {
        require(msg.sender == crafter);
        nftInfo[_id].breedCount = _breedCount;
    }
    
    function getBreedCount(uint256 _id) public view returns(uint){
        return nftInfo[_id].breedCount;
    }

    function setLastBreedTime(uint256 _id, uint256 _lastBreedTime) public {
        require(msg.sender == crafter);
        nftInfo[_id].lastBreedTime = _lastBreedTime;
    }
    
    function getLastBreedTime(uint256 _id) public view returns(uint256){
        return nftInfo[_id].lastBreedTime;
    }

    function setParents(uint256 _id, uint256 _parent1ID, uint256 _parent2ID) public {
        require(msg.sender == crafter);
        nftInfo[_id].parent1ID = _parent1ID;
        nftInfo[_id].parent2ID = _parent2ID;
    }
    
    function getParents(uint256 _id) public view returns(uint256 _parent1ID, uint256 _parent2ID){
        return (nftInfo[_id].parent1ID, nftInfo[_id].parent2ID);
    }

    function isParent(uint256 _nft1, uint256 _nft2) public view returns(bool){
        return (nftInfo[_nft1].parent1ID == _nft2 || nftInfo[_nft1].parent2ID == _nft2);
    }

}

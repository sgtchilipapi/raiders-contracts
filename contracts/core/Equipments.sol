//SPDX-License-Identifier: MIT
/**
    @title Equipment
    @author Eman "Sgt"
    @notice: NFT Contract for items equippable to characters. Originally created for CHAINLINK HACKATHON FALL 2022
*/
pragma solidity =0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/Counters.sol";
import "../libraries/StructLibrary.sol";

contract Equipments is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private equipment_ids;

    ///Map out a specific equipment NFT id to its properties {equipment_type, dominant_stat, rarity, extremity}
    mapping (uint256 => equipment_properties) public equipment;

    ///Map out a specific equipment NFT id to its stats {atk, def, eva, ...}
    mapping (uint256 => equipment_stats) public stats;

    ///The address for the minter router
    address private equipment_minter;

    event EquipmentMinted(uint256 indexed equipment_id, equipment_properties equipment_props);

    constructor() ERC721("Equipments", "EQPTS") {
    }

    function isOwner(address _owner, uint256 _equipment) public view returns (bool){
        return super._isApprovedOrOwner(_owner, _equipment);
    }

    ///@notice This function mints the equipment requested and maps out its properties and stats.
    ///Can only be called by the designated minter.
    function _mintEquipment(equipment_properties memory equipment_props, equipment_stats memory _equipment_stats) external onlyMinter {
        equipment_ids.increment();
        equipment[equipment_ids.current()] = equipment_props;
        stats[equipment_ids.current()] = _equipment_stats;
        _mint(msg.sender, equipment_ids.current());
        emit EquipmentMinted(equipment_ids.current(), equipment[equipment_ids.current()]);
    }

    ///@notice This function sets the minter contract.
    function setMinter(address minterAddress) public onlyOwner{
        equipment_minter = minterAddress;
    }

    ///@notice Custom modifier to only allow the minter for some functions.
    modifier onlyMinter(){
        require(msg.sender == equipment_minter,"EQPTS: Can only be called by the Router Minter.");
        _;
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}


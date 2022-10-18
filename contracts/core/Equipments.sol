//SPDX-License-Identifier: MIT
/**
    @title Equipment
    @author Eman Garciano
    @notice: NFT Contract for items equippable to characters. Originally created for CHAINLINK HACKATHON FALL 2022
*/
pragma solidity =0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "../utils/Counters.sol";
import "../libraries/StructLibrary.sol";
import "../libraries/materials/EquipmentLibrary.sol";

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
    function _mintEquipment(address user, equipment_properties memory equipment_props, equipment_stats memory _equipment_stats) external onlyMinter {
        equipment_ids.increment();
        equipment[equipment_ids.current()] = equipment_props;
        stats[equipment_ids.current()] = _equipment_stats;
        _mint(user, equipment_ids.current());
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

    ///@notice Instead of storing the tokenURI using setTokenURI, we are constructing it as it is being queried.
    ///The reason for this is to save up on mints as it is done by our VRF's fulfillRandomWords()
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory tokenURIString)
    {
        require(
            super._exists(tokenId),
            "ERC721URIStorage: URI query for nonexistent token"
        );
        equipment_properties memory _equipment = equipment[tokenId];
        equipment_details memory _details = EquipmentLibrary.getEquipment(_equipment);
        tokenURIString = encodeStrings(_details);
    }

    ///@notice Encodes the strings into a JSON string
    function encodeStrings(equipment_details memory _details) internal pure returns (string memory uriJSON){
        uriJSON = string(
            abi.encodePacked(
            "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"description": "RandomClash Equipment", "image": "',
                            _details.image,'", "name": "', _details.name, '", "attributes": [',
                            '{"trait_type": "equipment_type", "value": "',_details.type_tag,'"}, {"trait_type": "rarity", "value": "',_details.rarity_tag,'"}, {"trait_type": "aptitude", "value": "',_details.dominant_stat_tag,'"}, {"trait_type": "extremity", "value": "',_details.extremity_tag,
                            '"}]}'
                        )
                    )
                )
            )
        );
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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}


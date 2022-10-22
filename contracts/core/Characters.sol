// SPDX-License-Identifier: MIT
/**
    @title Characters
    @author Eman "Sgt"
    @notice: NFT Contract for playable characters.
    Originally created for CHAINLINK HACKATHON FALL 2022
*/
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../utils/Counters.sol";
import "../utils/BreakdownUint256.sol";
import "../libraries/characters/CharacterLibrary.sol";
import "../libraries/characters/CharacterStatsCalculator.sol";
import "../libraries/StructLibrary.sol";
interface _EquipmentManager {
    function unEquipAllFromTransfer(uint256 _character_id) external;
}

contract Characters is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private character_ids;
    _EquipmentManager equipmentManager;

    ///Map out a specific character NFT id to its properties {character_class, element, str, vit, dex, mood, exp}
    mapping (uint256 => character_properties) public character;
    mapping(uint256 => string) public character_name;

    ///The address for the minter router
    address private character_minter;

    event CharacterMinted(uint256 indexed character_id, character_properties character_props);

    constructor() ERC721("Characters", "CTRS") {
    }

    function _mintCharacter(address user, character_properties memory character_props, string memory _character_name) public onlyMinter{
        character_ids.increment();
        character[character_ids.current()] = character_props;
        character_name[character_ids.current()] = _character_name;
        _mint(user, character_ids.current());
        emit CharacterMinted(character_ids.current(), character[character_ids.current()]);
    }    

    ///@notice This function sets the minter contract.
    function setMinter(address minterAddress) public onlyOwner{
        character_minter = minterAddress;
    }

    ///@notice Custom modifier to only allow the minter for some functions.
    modifier onlyMinter(){
        require(msg.sender == character_minter,"CTRS: Can only be called by the Router Minter.");
        _;
    }

    ///@notice We expose a pubic `isOwner` for use in our other contracts.
    function isOwner(address _owner, uint256 _character) public view returns (bool){
        return super._isApprovedOrOwner(_owner, _character);
    }

    ///@notice This function sets the equipment manager contract.
    function setEquipmentManager(address managerAddress) public onlyOwner{
        equipmentManager = _EquipmentManager(managerAddress);
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
        character_properties memory character_props = character[tokenId];
        character_uri_details memory uri_details = CharacterLibrary.getCharacter(character_props.character_class, character_props.mood);
        tokenURIString = encodeStrings(character_props, uri_details, character_name[tokenId]);
    }

    ///@notice Encodes the strings into a JSON string
    function encodeStrings(character_properties memory character_props, character_uri_details memory uri_details, string memory _character_name) internal pure returns (string memory uriJSON){
        uriJSON = string(
            abi.encodePacked(
            "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"description": "RandomClash Character", "image": "',uri_details.image,'", "name": "', _character_name,
                            '", "attributes": [',
                                '{"trait_type": "character_class", "value": "', uri_details.name,
                                '"}, {"display_type": "number", "trait_type": "strength", "max_value": 1000, "value": ', Strings.toString(character_props.str),
                                '}, {"display_type": "number", "trait_type": "vitality", "max_value": 1000, "value": ', Strings.toString(character_props.vit),
                                '}, {"display_type": "number", "trait_type": "dexterity", "max_value": 1000, "value": ', Strings.toString(character_props.dex),
                                '}, {"display_type": "number", "trait_type": "experience", "value": "', Strings.toString(character_props.exp),
                                '"}, {"trait_type": "element", "value": "', CharacterLibrary.getElement(character_props.element),
                                '"}, {"display_type": "boost_percentage", "trait_type": "', uri_details.bonus,'", "value": ',uri_details.bonus_value,'}, ',
                                '{"display_type": "boost_percentage", "trait_type": "', CharacterLibrary.getTalent(character_props.talent),
                                '", "value": 10}, {"trait_type": "mood", "value": "',uri_details.mood,'"}',
                            ']}'
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
        ///@notice The unequip function in the managere would only fire from subsequent transfers after the initial transfer from mint.
        if(from != address(0)){
            equipmentManager.unEquipAllFromTransfer(tokenId);
        }
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
// SPDX-License-Identifier: MIT
/**
    @title Characters
    @author Eman @SgtChiliPapi
    @notice: NFT Contract for playable characters.
    Originally created for CHAINLINK HACKATHON FALL 2022
*/
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../../periphery/utils/Counters.sol";
import "../../periphery/libraries/characters/CharacterLibrary.sol";
import "../../periphery/libraries/characters/CharacterStatsCalculator.sol";

interface _EquipmentManager {
    function unequipAllFromTransfer(uint256 _character_id) external;
}

interface _CharacterUriConstructor {
    function encodeStrings(character_properties memory character_props, character_uri_details memory uri_details, string memory _character_name) external pure returns (string memory uriJSON);
}

contract Characters is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private character_ids;
    _EquipmentManager equipmentManager;
    _CharacterUriConstructor characterUriConstructor;

    ///Map out a specific character NFT id to its properties {character_class, element, str, vit, dex, mood, exp}
    mapping (uint256 => character_properties) public character;
    mapping(uint256 => string) public character_name;

    ///The address for the minter router
    address private character_minter;

    ///The address for the character updater
    address private dungeon;

    event CharacterMinted(uint256 indexed character_id, address user, string char_name, character_properties character_props);
    event CharacterUpdated(uint256 indexed character_id, character_properties character_props);
    event CharacterRenamed(uint256 indexed character_id, string char_name);

    constructor() ERC721("Characters", "CTRS") {
    }

    function _mintCharacter(address user, character_properties memory character_props, string memory _character_name) public onlyMinter{
        character_ids.increment();
        character[character_ids.current()] = character_props;
        character_name[character_ids.current()] = _character_name;
        _mint(user, character_ids.current());
        emit CharacterMinted(character_ids.current(), user, character_name[character_ids.current()], character[character_ids.current()]);
    }

    ///@notice An easy way of fetching real-time character data. No need to create a subgraph for this.
    function getCharacter(uint256 character_id) public view returns (string memory char_name, character_properties memory char_props, battle_stats memory char_stats){
        char_name = character_name[character_id];
        char_props = character[character_id];
        char_stats = CharacterStatsCalculator.getCharacter(char_props);
    }

    ///@notice This function can only be called by the updater contract which shall be responsible for doing the necessary checks.
    function updateCharacter(uint256 tokenId, character_properties memory updated_props) public onlyDungeon{
        character[tokenId] = updated_props;
        emit CharacterUpdated(tokenId, updated_props);
    }

    ///@notice This function renames the character chosen which can only be called by the owner of such character.
    function renameCharacter(uint256 tokenId, string memory new_name) public {
        require(isOwner(msg.sender, tokenId), 'Cannot rename character not owned.');
        character_name[tokenId] = new_name;
        emit CharacterRenamed(tokenId, new_name);
    }    

    ///@notice This function sets the minter contract.
    function setMinter(address minterAddress) public onlyOwner{
        character_minter = minterAddress;
    }

    ///@notice Custom modifier to only allow the minter for some functions.
    modifier onlyMinter(){
        require(msg.sender == character_minter);
        _;
    }

    ///@notice Custom modifier to only allow the character updater contract for some functions.
    modifier onlyDungeon(){
        require(msg.sender == dungeon);
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

    ///@notice This function sets the uri constructor contract.
    function setUriConstructor(address uriConstructorAddress) public onlyOwner{
        characterUriConstructor = _CharacterUriConstructor(uriConstructorAddress);
    }

    ///@notice This function sets the character properties updater contract.
    function setDungeon(address dungeonAddress) public onlyOwner{
        dungeon = dungeonAddress;
    }

    ///@notice Instead of storing the tokenURI using setTokenURI, we are constructing it as it is being queried.
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721)
        returns (string memory tokenURIString)
    {
        require(
            super._exists(tokenId),
            "Nonexistent"
        );
        character_properties memory character_props = character[tokenId];
        character_uri_details memory uri_details = CharacterLibrary.getCharacter(character_props.character_class, character_props.mood, character_props.talent);
        tokenURIString = characterUriConstructor.encodeStrings(character_props, uri_details, character_name[tokenId]);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {   
        ///@notice The unequip function in the managere would only fire from subsequent transfers after the initial transfer from mint.
        if(from != address(0)){
            equipmentManager.unequipAllFromTransfer(tokenId);
        }
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721) {
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
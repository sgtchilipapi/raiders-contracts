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
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../../periphery/utils/Counters.sol";
import "../../periphery/libraries/characters/CharacterLibrary.sol";
// import "../../periphery/libraries/characters/CharacterStatsCalculator.sol";

interface _EquipmentManager {
    function unEquipAllFromTransfer(uint256 _character_id) external;
}

contract Characters is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private character_ids;
    _EquipmentManager equipmentManager;

    ///Map out a specific character NFT id to its properties {character_class, element, str, vit, dex, mood, exp}
    mapping (uint256 => character_properties) public character;
    mapping(uint256 => string) public character_name;

    ///The address for the minter router
    address private character_minter;

    ///The address for the character updater
    address private dungeon;

    event CharacterMinted(uint256 indexed character_id, character_properties character_props);
    event CharacterUpdated(uint256 indexed character_id, character_properties character_props);

    constructor() ERC721("Characters", "CTRS") {
    }

    function _mintCharacter(address user, character_properties memory character_props, string memory _character_name) public onlyMinter{
        character_ids.increment();
        character[character_ids.current()] = character_props;
        character_name[character_ids.current()] = _character_name;
        _mint(user, character_ids.current());
        emit CharacterMinted(character_ids.current(), character[character_ids.current()]);
    }

    ///@notice This function can only be called by the updater contract which shall be responsible for doing the necessary checks.
    function updateCharacter(uint256 tokenId, character_properties memory updated_props) public onlyDungeon{
        character[tokenId] = updated_props;
        emit CharacterUpdated(tokenId, updated_props);
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
        character_uri_details memory uri_details = CharacterLibrary.getCharacter(character_props.character_class, character_props.mood);
        tokenURIString = encodeStrings(character_props, uri_details, character_name[tokenId]);
    }

    ///@notice Encodes the strings into a JSON string
    function encodeStrings(character_properties memory character_props, character_uri_details memory uri_details, string memory _character_name) internal pure returns (string memory uriJSON){
        uriJSON =
            string.concat(
            "data:application/json;base64,",
                Base64.encode(
                    abi.encodePacked(
                                encodeDetails(uri_details, _character_name),
                                encodeProps(character_props)
                                ///encodeStats(CharacterStatsCalculator.getCharacterStats(character_props))
                    )
                )
            );
    }

    function encodeDetails(character_uri_details memory uri_details, string memory _character_name) internal pure returns (string memory details_part){
        details_part = string.concat(
                            '{"description": "RandomClash Character", "image": "',uri_details.image,'", "name": "', _character_name,
                            '", "attributes": [',
                                '{"trait_type": "character_class", "value": "', uri_details.name,
                                '"}, {"display_type": "boost_percentage", "trait_type": "', uri_details.bonus,'", "value": ',uri_details.bonus_value,'}, ',
                                '{"trait_type": "mood", "value": "',uri_details.mood,'"}'
        );
    }

    function encodeProps(character_properties memory character_props) internal pure returns (string memory props_part){
        props_part = string.concat(
                                ', {"display_type": "number", "trait_type": "STR", "value": ', Strings.toString(character_props.str),
                                '}, {"display_type": "number", "trait_type": "VIT", "value": ', Strings.toString(character_props.vit),
                                '}, {"display_type": "number", "trait_type": "DEX", "value": ', Strings.toString(character_props.dex),
                                '}, {"trait_type": "LVL", "value": ', Strings.toString((character_props.exp / 100) + 1),
                                '}, {"trait_type": "element", "value": "', CharacterLibrary.getElement(character_props.element),
                                '"}, {"display_type": "boost_percentage", "trait_type": "', CharacterLibrary.getTalent(character_props.talent),
                                '", "value": 10}]}' /// <<< attributes array and JSON uri closes here
        );
    }

    ///@notice Removing the stats section in the URI due to the code size exceeding 24,576 bytes.
    // function encodeStats(character_stats memory _stats) internal pure returns (string memory stats_part){
    //     stats_part = string.concat(
                            // ', {"trait_type": "ATK", "value": ', Strings.toString(_stats.atk),
                            // '}, {"trait_type": "DEF", "value": ', Strings.toString(_stats.def),
                            // '}, {"trait_type": "EVA %", "value": ', Strings.toString(_stats.eva / 10),
                            // '}, {"trait_type": "HP", "value": ', Strings.toString(_stats.hp),
                            // '}, {"trait_type": "PEN %", "value": ', Strings.toString(_stats.pen / 10),
                            // '}, {"trait_type": "CRIT %", "value": ', Strings.toString(_stats.crit / 10),
                            // '}, {"trait_type": "LUK %", "value": ', Strings.toString(_stats.luck / 10),
                            // '}, {"trait_type": "RES %", "value": ', Strings.toString(_stats.energy_regen / 10),
    //                         '}]}' /// <<< attributes array and JSON uri closes here
    //     );
    // }

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
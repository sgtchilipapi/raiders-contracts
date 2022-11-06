///SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./CharacterLibrary.sol";
import "./CharacterStatsCalculator.sol";

contract CharacterUriConstructor {

    ///@notice Encodes the strings into a JSON string
    function encodeStrings(character_properties memory character_props, character_uri_details memory uri_details, string memory _character_name) public pure returns (string memory uriJSON){
        uriJSON =
            string.concat(
            "data:application/json;base64,",
                Base64.encode(
                    abi.encodePacked(
                                encodeDetails(uri_details, _character_name),
                                encodeProps(character_props),
                                encodeStats(CharacterStatsCalculator.getCharacter(character_props))
                    )
                )
            );
    }

    function encodeDetails(character_uri_details memory uri_details, string memory _character_name) internal pure returns (string memory details_part){
        details_part = string.concat(
                            '{"description": "Characters", "image": "',uri_details.image,'", "name": "', _character_name,
                            '", "attributes": [',
                                '{"trait_type": "character_class", "value": "', uri_details.name,
                                '"}, {"display_type": "boost_percentage", "trait_type": "', uri_details.bonus,'", "value": ',uri_details.bonus_value,'}, ',
                                '{"trait_type": "mood", "value": "',uri_details.mood,'"}'
        );
    }

    function encodeProps(character_properties memory character_props) internal pure returns (string memory props_part){
        props_part = string.concat(
                                ', {"trait_type": "STR", "max_value": 1000, "value": ', Strings.toString(character_props.str),
                                '}, {"trait_type": "VIT", "max_value": 1000, "value": ', Strings.toString(character_props.vit),
                                '}, {"trait_type": "DEX", "max_value": 1000, "value": ', Strings.toString(character_props.dex),
                                '}, {"trait_type": "Character Level", "max_value": 100, "value": ', Strings.toString((character_props.exp / 100) + 1),
                                '}, {"trait_type": "element", "value": "', CharacterLibrary.getElement(character_props.element),
                                '"}, {"display_type": "boost_percentage", "trait_type": "', CharacterLibrary.getTalent(character_props.talent),
                                '", "value": 10}'
        );
    }

    function encodeStats(battle_stats memory _stats) internal pure returns (string memory stats_part){
        stats_part = string.concat(
                            ', {"display_type": "number", "trait_type": "ATK", "max_value": 9999, "value": ', Strings.toString(_stats.atk),
                            '}, {"display_type": "number", "trait_type": "DEF", "max_value": 9999, "value": ', Strings.toString(_stats.def),
                            '}, {"display_type": "number", "trait_type": "EVA", "max_value": 1000, "value": ', Strings.toString(_stats.eva),
                            '}, {"display_type": "number", "trait_type": "HP", "max_value": 9999, "value": ', Strings.toString(_stats.hp),
                            '}, {"display_type": "number", "trait_type": "PEN", "max_value": 1000, "value": ', Strings.toString(_stats.pen),
                            '}, {"display_type": "number", "trait_type": "CRIT", "max_value": 1000, "value": ', Strings.toString(_stats.crit),
                            '}, {"display_type": "number", "trait_type": "LUK", "max_value": 1000, "value": ', Strings.toString(_stats.luck),
                            '}, {"display_type": "number", "trait_type": "RES", "max_value": 1000, "value": ', Strings.toString(_stats.energy_restoration),
                            '}]}' /// <<< attributes array and JSON uri closes here
        );
    }
}


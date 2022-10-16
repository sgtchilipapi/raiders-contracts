//SPDX-License-Identifier: MIT
//EquipmentLibrary.sol

/**
    @title Equipment Library
    @author Eman 'Sgt' Garciano https://www.linkedin.com/in/eman-garciano-04a14211a/
    @notice This library constructs the name and image URL of an equipment according to its type, rarity, dominant stat, and dominance extremity.
            Originally made for a submission to CHAINLINK HACKATHON 2022.
 */

pragma solidity =0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";
import "../../libraries/StructLibrary.sol";

library EquipmentLibrary {
    function getEquipment(equipment_properties memory equipment) internal pure returns (equipment_details memory details){
        (uint256 _rarity, uint256 _equipment_type, uint256 _extremity, uint256 _dominant_stat) = (equipment.rarity, equipment.equipment_type, equipment.extremity, equipment.dominant_stat);
        (string memory rarity_tag, string memory rarity_image) = getRarityTag(_rarity);
        (string memory _type, string memory type_image) = getEquipmentType(_equipment_type, _dominant_stat);
        string memory extremity_tag = getExtremityTag(_extremity);
        (string memory dominant_stat_tag, string memory dominant_stat_image) = getDominantStatTag(_dominant_stat);
        string memory baseURL = "https://chainlink-rpg2022.infura-ipfs.io/ipfs/QmafBnEx6sLXR1nLAdsTxcaANo9hTrD9z21LUuaqeFJJka/";
        details = equipment_details({
            name: string.concat(rarity_tag, _type, extremity_tag, dominant_stat_tag),
            image: string.concat(baseURL, type_image, dominant_stat_image, rarity_image)
        });
    }

    /**
    {
        "description": "Friendly OpenSea Creature that enjoys long swims in the ocean.", 
        "external_url": "https://openseacreatures.io/3", 
        "image": "https://storage.googleapis.com/opensea-prod.appspot.com/puffs/3.png", 
        "name": "Dave Starbelly",
        "attributes": [ ... ], 
    }

    {
        "attributes": [
            {
            "trait_type": "Base", 
            "value": "Starfish"
            },
        ] 
     */

    function getEquipmentType(uint256 equipment_type, uint256 dominant_stat) internal pure returns (string memory _type, string memory type_image){
        if(equipment_type == 0){_type = "Helm "; type_image = "HELMS/";}
        if(equipment_type == 1){_type = "Armor "; type_image = "ARMORS/";}
        if(equipment_type == 2){_type = getWeapon(dominant_stat); type_image = "WEAPONS/";}
        if(equipment_type == 3){_type = getAccessory(dominant_stat); type_image = "ACCESSORIES/";}
    }

    function getRarityTag(uint256 rarity) internal pure returns (string memory rarity_tag, string memory rarity_image){
        if(rarity == 0){rarity_tag = "Common "; rarity_image = "COMM.png";}
        if(rarity == 1){rarity_tag = "Uncommon "; rarity_image = "UNCO.png";}
        if(rarity == 2){rarity_tag = "Scarce "; rarity_image = "SCAR.png";}
        if(rarity == 3){rarity_tag = "Rare "; rarity_image = "RARE.png";}
        if(rarity == 4){rarity_tag = "Unique "; rarity_image = "UNIQ.png";}
    }

    function getExtremityTag(uint256 extremity) internal pure returns (string memory extremity_tag){
        if(extremity == 0){extremity_tag = "of ";}
        if(extremity == 1){extremity_tag = "of Minor ";}
        if(extremity == 2){extremity_tag = "of Good ";}
        if(extremity == 3){extremity_tag = "of Great ";}
        if(extremity == 4){extremity_tag = "of Intense ";}
        if(extremity == 5){extremity_tag = "of Extraordinary ";}
        if(extremity == 6){extremity_tag = "of Ethereal ";}
        if(extremity == 7){extremity_tag = "of Astronomical ";}
        if(extremity == 8){extremity_tag = "of Divine ";}
    }

    function getDominantStatTag(uint256 dominant_stat) internal pure returns (string memory dominant_tag, string memory dominant_stat_image){
        if(dominant_stat == 0){dominant_tag = "Vigor"; dominant_stat_image = "ATK/";}
        if(dominant_stat == 1){dominant_tag = "Resistance"; dominant_stat_image = "DEF/";}
        if(dominant_stat == 2){dominant_tag = "Elusiveness"; dominant_stat_image = "EVA/";}
        if(dominant_stat == 3){dominant_tag = "Health"; dominant_stat_image = "HP/";}
        if(dominant_stat == 4){dominant_tag = "Ferocity"; dominant_stat_image = "PEN/";}
        if(dominant_stat == 5){dominant_tag = "Precision"; dominant_stat_image = "CRIT/";}
        if(dominant_stat == 6){dominant_tag = "Sight"; dominant_stat_image = "LUK/";}
        if(dominant_stat == 7){dominant_tag = "Restoration"; dominant_stat_image = "REG/";}
    }

    function getWeapon(uint256 dominant_stat) internal pure returns (string memory weapon){
        if(dominant_stat == 0){weapon = "Hammer ";}
        if(dominant_stat == 1){weapon = "Shield ";}
        if(dominant_stat == 2){weapon = "Dagger ";}
        if(dominant_stat == 3){weapon = "Club ";}
        if(dominant_stat == 4){weapon = "Axe ";}
        if(dominant_stat == 5){weapon = "Bombard ";}
        if(dominant_stat == 6){weapon = "Sling ";}
        if(dominant_stat == 7){weapon = "Staff ";}
    }

    function getAccessory(uint256 dominant_stat) internal pure returns (string memory accessory){
        if(dominant_stat % 2 == 0){accessory = "Ring ";}
        if(dominant_stat % 2 == 1){accessory = "Amulet ";}
    }
}


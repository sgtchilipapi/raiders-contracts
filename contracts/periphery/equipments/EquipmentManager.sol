//SPDX-License-Identifier: MIT
/**
    @title Equipment Manager
    @author Eman @SgtChiliPapi
    @notice: Contract to map equipment items to characters and vice-versa.
    Originally created for CHAINLINK HACKATHON FALL 2022
*/
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/structs/CharacterStructs.sol";
import "../libraries/structs/EquipmentStructs.sol";

interface ICharacters {
    function isOwner(address _owner, uint256 _character) external view returns (bool);
    function character(uint256 _character_id) external view returns (character_properties memory);
}

interface IEquipment {
    function isOwner(address _owner, uint256 _equipment) external view returns (bool);
    function equipment(uint256 _equipment_id) external view returns (equipment_properties memory);
}

contract EquipmentManager {

    ///Instantiate contract links for ownership checks and properties references.
    ICharacters character_contract;
    IEquipment equipment_contract;
    address private character_contract_address;
    address private equipment_contract_address;

    mapping(uint256 => uint256) public equippedTo;//POV Equipment Item: Specify the character currently the item is equipped to.
    mapping (uint256 => character_equipments) public equippedWith; //POV Character: Specify the items currently equipped to the character.

    event ItemEquipped(uint256 indexed character_id,  uint256 indexed equipment_id, uint256 equipment_type);
    event ItemUnequipped(uint256 indexed character_id, uint256 indexed equipment_id, uint256 equipment_type);

    constructor(address character_address, address equipment_address){
        character_contract_address = character_address;
        equipment_contract_address = equipment_address;
        character_contract = ICharacters(character_address);
        equipment_contract = IEquipment(equipment_address);
    }

    ///@notice This function equips an equipment to a character.
    function equip(uint256 _character_id, uint256 _equipment_id) public{
        //Ownership checks for character and equipment.
        require(character_contract.isOwner(msg.sender, _character_id), "EQPD: Cannot equip to a character not owned.");
        require(equipment_contract.isOwner(msg.sender, _equipment_id), "EQPD: Cannot equip with equipment not owned.");

        ///Fetch equipment properties from their respective contracts.
        equipment_properties memory equipment =  equipment_contract.equipment(_equipment_id);

        ///Check if the items is equippable
        require(equipment.equipment_type < 4, "EQPD: Item not equippable.");

        //Reference the equipment's _type prop to update the appropriate equipment slot (helm, armor, weapon, accessory) of the character.
        if(equipment.equipment_type == 0){equipWeapon(_character_id, _equipment_id);}
        if(equipment.equipment_type == 1){equipHelm(_character_id, _equipment_id);}
        if(equipment.equipment_type == 2){equipArmor(_character_id, _equipment_id);}
        if(equipment.equipment_type == 3){equipAccessory(_character_id, _equipment_id);}
    }

    ///@notice For multiple equipments to be equipped to a character in one transaction, simply loop through the equipments specified.
    function equipMany(uint256 _character_id, uint256[] memory _equipment_ids) public{
        require(_equipment_ids.length < 5, "EQPD: Cannot equip more than 4 items."); //Safety check to save users gas.
        for(uint256 i = 0; i < _equipment_ids.length; i++){
            equip(_character_id, _equipment_ids[i]);
        }
    }

    ///@notice This function effectively unequips the 'helm to be equipped' from the character it is currently equipped to.
    ///Also, the current helm (if any) of the 'character to be equipped to' will be unequipped as well. 
    function equipHelm(uint256 _character_id, uint256 _equipment_id) internal {
        //1st Unequip from the character it is currently equipped to
        uint256 currentlyEquippedTo = equippedTo[_equipment_id]; //Check for the current character
        if(currentlyEquippedTo != 0) { unequipHelm(currentlyEquippedTo);}

        //2nd Unequip the character's current equipment
        unequipHelm(_character_id);
        
        //Lastly, equip the item to the character
        equippedTo[_equipment_id] = _character_id;
        equippedWith[_character_id].headgear = uint64(_equipment_id);
        emit ItemEquipped(_character_id, _equipment_id, 1); //1 => headgear
    }

    ///@notice Same effect with equipHelm but for Armors.
    function equipArmor(uint256 _character_id, uint256 _equipment_id) internal{
        //1st Unequip from the character it is currently equipped to
        uint256 currentlyEquippedTo = equippedTo[_equipment_id]; //Check for the current character
        if(currentlyEquippedTo != 0) { unequipArmor(currentlyEquippedTo);}

        //2nd Unequip the character's current equipment
        unequipArmor(_character_id);
        
        //Lastly, equip the item to the character
        equippedTo[_equipment_id] = _character_id;
        equippedWith[_character_id].armor = uint64(_equipment_id);
        emit ItemEquipped(_character_id, _equipment_id, 2); //2 => armor
    }

    ///@notice Same effect with equipHelm but for Weapons.
    function equipWeapon(uint256 _character_id, uint256 _equipment_id) internal{
        //1st Unequip from the character it is currently equipped to
        uint256 currentlyEquippedTo = equippedTo[_equipment_id]; //Check for the current character
        if(currentlyEquippedTo != 0) { unequipWeapon(currentlyEquippedTo);}

        //2nd Unequip the character's current equipment
        unequipWeapon(_character_id);
        
        //Lastly, equip the item to the character
        equippedTo[_equipment_id] = _character_id;
        equippedWith[_character_id].weapon = uint64(_equipment_id);
        emit ItemEquipped(_character_id, _equipment_id, 0); //0 => weapon
    }

    ///@notice Same effect with equipHelm but for Accessories.
    function equipAccessory(uint256 _character_id, uint256 _equipment_id) internal{
        //1st Unequip from the character it is currently equipped to
        uint256 currentlyEquippedTo = equippedTo[_equipment_id]; //Check for the current character
        if(currentlyEquippedTo != 0) { unequipAccessory(currentlyEquippedTo);}

        //2nd Unequip the character's current equipment
        unequipAccessory(_character_id);
        
        //Lastly, equip the item to the character
        equippedTo[_equipment_id] = _character_id;
        equippedWith[_character_id].accessory = uint64(_equipment_id);
        emit ItemEquipped(_character_id, _equipment_id, 3); //3 => headgear
    }

    ///@notice The owner of the character can unequip items by type (headgear, armor, weapon, accessory)
    function unEquipType(uint256 _character_id, uint256 equipment_type) public{
        require(character_contract.isOwner(msg.sender, _character_id), "EQPD: Cannot unequip from character not owned.");
        if(equipment_type == 0){unequipWeapon(_character_id);}
        if(equipment_type == 1){unequipHelm(_character_id);}
        if(equipment_type == 2){unequipArmor(_character_id);}
        if(equipment_type == 3){unequipAccessory(_character_id);}
    }

    ///@notice The owner can unequip everything from his character
    function unEquipAll(uint256 _character_id) public{
        require(character_contract.isOwner(msg.sender, _character_id), "EQPD: Cannot unequip from character not owned.");
        unequipHelm(_character_id);
        unequipArmor(_character_id);
        unequipWeapon(_character_id);
        unequipAccessory(_character_id);
    }

    ///@notice This function is triggered everytime an equipment item is transferred
    function unEquipItemFromTransfer(uint256 _equipment_id) external onlyEquipmentContract returns (bool success){
        if(equippedTo[_equipment_id] != 0){
            equipment_properties memory equipment =  equipment_contract.equipment(_equipment_id);
            if(equipment.equipment_type == 0){unequipWeapon(equippedTo[_equipment_id]);}
            if(equipment.equipment_type == 1){unequipHelm(equippedTo[_equipment_id]);}
            if(equipment.equipment_type == 2){unequipArmor(equippedTo[_equipment_id]);}
            if(equipment.equipment_type == 3){unequipAccessory(equippedTo[_equipment_id]);}
        }
        success = true;
    }

    ///@notice This is triggered everytime a character is transferred
    function unEquipAllFromTransfer(uint256 _character_id) external onlyCharacterContract returns (bool success){
        unequipHelm(_character_id);
        unequipArmor(_character_id);
        unequipWeapon(_character_id);
        unequipAccessory(_character_id);
        success = true;
    }

    function unequipHelm(uint256 _character_id) internal {
        uint256 _equipment_id = equippedWith[_character_id].headgear;
        equippedTo[_equipment_id] = 0;
        equippedWith[_character_id].headgear = 0;
        emit ItemUnequipped(_character_id, _equipment_id, 1);
        
    }

    function unequipArmor(uint256 _character_id) internal {
        uint256 _equipment_id = equippedWith[_character_id].armor;
        equippedTo[_equipment_id] = 0;
        equippedWith[_character_id].armor = 0;
        emit ItemUnequipped(_character_id, _equipment_id, 2);
    }

    function unequipWeapon(uint256 _character_id) internal {
        uint256 _equipment_id = equippedWith[_character_id].weapon;
        equippedTo[_equipment_id] = 0;
        equippedWith[_character_id].weapon = 0;
        emit ItemUnequipped(_character_id, _equipment_id, 0);
    }

    function unequipAccessory(uint256 _character_id) internal {
        uint256 _equipment_id = equippedWith[_character_id].accessory;
        equippedTo[_equipment_id] = 0;
        equippedWith[_character_id].accessory = 0;
        emit ItemUnequipped(_character_id, _equipment_id, 3);
    }

    modifier onlyCharacterContract() {
        require(msg.sender == character_contract_address);
        _;
    }

    modifier onlyEquipmentContract(){
        require(msg.sender == equipment_contract_address);
        _;
    }

}
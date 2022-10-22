//SPDX-License-Identifier: MIT
/**
    @title Struct Library
    @author Eman Garciano
    @notice: Reference for structs across contracts. 
    Originally created for CHAINLINK HACKATHON FALL 2022
*/

pragma solidity =0.8.17;

/*
    Character Classes Reference:
    1. Viking
    2. Woodcutter
    3. Troll
    4. Mechanic
    5. Amphibian
    6. Graverobber
*/







struct attack_event {
    uint256 attack_index;
    uint256 challenger_hp;
    uint256 defender_hp;
    uint256 evaded;
    uint256 critical_hit;
    uint256 penetrated;
    uint256 damage_to_challenger;
    uint256 damage_to_defender;  
}





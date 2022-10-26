//SPDX-License-Identifier: MIT
/**
    @title Struct Library
    @author Eman Garciano
    @notice: Reference for global structs across contracts. 
    Originally created for CHAINLINK HACKATHON FALL 2022
*/

pragma solidity =0.8.17;

struct battle_stats {
    uint256 atk;
    uint256 def;
    uint256 eva;
    uint256 hp;
    uint256 pen;
    uint256 crit;
    uint256 luck;
    uint256 energy_restoration;
}







// struct attack_event {
//     uint256 attack_index;
//     uint256 challenger_hp;
//     uint256 defender_hp;
//     uint256 evaded;
//     uint256 critical_hit;
//     uint256 penetrated;
//     uint256 damage_to_challenger;
//     uint256 damage_to_defender;  
// }





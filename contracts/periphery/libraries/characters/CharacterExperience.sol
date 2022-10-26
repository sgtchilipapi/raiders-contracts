//SPDX-License-Identifier: MIT
/**
    @title Character Experience
    @author Eman "Sgt"
    @notice: Reference for character experience and attribute gains in dungeons.
            A simple library. Might prove useful when the experience and leveling system is further improved in complexity.
    Originally created for CHAINLINK HACKATHON FALL 2022
*/
pragma solidity ^0.8.7;

library CharacterExperience {
    
    function getExpAndAttributeGains(uint256 tier) internal pure returns (uint32 experience, uint32 stat_gain){
        if(tier == 0){experience = 20; stat_gain = 1;}
        if(tier == 1){experience = 40; stat_gain = 3;}
        if(tier == 2){experience = 60; stat_gain = 6;}
        if(tier == 3){experience = 80; stat_gain = 10;}
        if(tier == 4){experience = 100; stat_gain = 15;}
    }

    function getAttributeAffected(uint256 dungeon) internal pure returns (uint32 stat){
        if(dungeon == 0){stat = 0;}
        if(dungeon == 1){stat = 1;}
        if(dungeon == 2){stat = 2;}
    }
}


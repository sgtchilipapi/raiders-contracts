///SPDX-License-Identifier: MIT

/**
    @title DungeonMaterials
    @author Eman @SgtChiliPapi
    @notice This library specifies the specific material rewards for each dungeon.
            Originally made for a submission to CHAINLINK HACKATHON 2022.
 */

 pragma solidity ^0.8.7;

 library DungeonMaterials {

    function getDungeonMaterials(uint256 dungeon, uint256 tier) internal pure returns (uint256 material, uint256 min_amount, uint256 max_amount){
        if(dungeon == 0){material = 0;}
        if(dungeon == 1){material = 1;}
        if(dungeon == 2){material = 2;}
        (min_amount, max_amount) = getAmount(tier);
    }

    function getAmount(uint256 tier) internal pure returns (uint256 min_amount, uint256 max_amount){
        if(tier == 0){min_amount = 1; max_amount = 3;}
        if(tier == 1){min_amount = 2; max_amount = 6;}
        if(tier == 2){min_amount = 3; max_amount = 9;}
        if(tier == 3){min_amount = 4; max_amount = 12;}
        if(tier == 4){min_amount = 5; max_amount = 15;}
    }
 }
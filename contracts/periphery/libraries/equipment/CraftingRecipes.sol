//SPDX-License-Identifier: MIT
//CraftingRecipes.sol

/**
    @title Crafting Recipes
    @author Eman @SgtChiliPapi
    @notice This library specifies what kind of materials (ERC20 tokens) are required to craft a particular equipment type.
            Originally made for a submission to CHAINLINK HACKATHON 2022.
 */

pragma solidity ^0.8.7;

import "../../libraries/structs/EquipmentStructs.sol";

library CraftingRecipes {
    function getRecipe(uint256 item_type) internal pure returns (item_recipe memory recipe){
        (uint256 main_m, uint256 main_a) = getMainMaterial(item_type);
        (uint256 indirect_m, uint256 indirect_a) = getIndirectMaterial(item_type);
        (uint256 catalyst_m, uint256 catalyst_a) = getCatalyst(item_type);

        recipe = item_recipe({
            main_material: main_m,
            indirect_material: indirect_m,
            catalyst: catalyst_m,
            main_material_amount: main_a,
            indirect_material_amount: indirect_a,
            catalyst_amount: catalyst_a
        });
    }

    function getMainMaterial(uint256 item_type) internal pure returns (uint256 material, uint256 amount){
        if(item_type == 0){material = 0; amount = 12 ether;} //WEAPONS: BOOMSTEEL
        if(item_type == 1){material = 1; amount = 12 ether;} //ARMORS: THUMPIRON
        if(item_type == 2){material = 1; amount = 6 ether;} //HELMS: THUMPIRON
        if(item_type == 3){material = 2; amount = 3 ether;} //ACCESSORIES: CLINKGLASS
        if(item_type == 4){material = 3; amount = 1 ether;} //CONSUMABLES: SNAPLINK
    }

    function getIndirectMaterial(uint256 item_type) internal pure returns (uint256 material, uint256 amount){
        if(item_type == 0){material = 1; amount = 4 ether;} //WEAPONS: THUMPIRON
        if(item_type == 1){material = 0; amount = 4 ether;} //ARMORS: BOOMSTEEL
        if(item_type == 2){material = 0; amount = 2 ether;} //HELMS: BOOMSTEEL
        if(item_type == 3){material = 0; amount = 1 ether;} //ACCESSORIES: BOOMSTEEL
        if(item_type == 4){material = 2; amount = 1 ether;} //CONSUMABLES: CLINKGLASS
    }

    function getCatalyst(uint256 item_type) internal pure returns (uint256 catalyst, uint256 amount){
        if(item_type == 0){catalyst = 0; amount = 4 ether;} //WEAPONS: YELLOW SPARKSTONE
        if(item_type == 1){catalyst = 1; amount = 4 ether;} //ARMORS: WHITE SPARKSTONE
        if(item_type == 2){catalyst = 1; amount = 2 ether;} //HELMS: WHITE SPARKSTONE
        if(item_type == 3){catalyst = 2; amount = 1 ether;} //ACCESSORIES: RED SPARKSTONE
        if(item_type == 4){catalyst = 3; amount = 250000000000000000 wei;} //CONSUMABLES: BLUE SPARKSTONE (1/4 bSPARK)
    }
}
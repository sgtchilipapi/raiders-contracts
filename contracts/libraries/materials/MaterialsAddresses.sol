//SPDX-License-Identifier: MIT
//EquipmentLibrary.sol

/**
    @title Materials Addresses Library
    @author Eman 'Sgt' Garciano https://www.linkedin.com/in/eman-garciano-04a14211a/
    @notice This library specifies the specific deployment addresses for each material (ERC20 tokens).
            Originally made for a submission to CHAINLINK HACKATHON 2022.
 */

 pragma solidity ^0.8.7;

 library MaterialsAddresses{
    /**
        @notice To bring down the complexity of the crafting mechanic, we are using only four kinds of materials and also four kinds of catalysts.
                This simplifies the farming and trading mechanics as well which makes it enjoyable even for casual players as well.
                However an inherent problem with this is that we lose a good amount of realism as to the material composition
                of a certain equipmet. For example: A leather armor is mainly made with leather while a plate armor is mainly made
                with iron or steel. But since we are using one primary ingredient for armors of different kinds, to make an example: 
                it would be unrealistic to craft a leather armor with iron. So our solution is to abstract away the nature of the
                materials into a sort of magical/very versatile kind of material that can be used for different kinds of equipment be 
                it soft textured or not.
     */
    function getMaterialAddress(uint256 material_index) internal pure returns (address material_address){
        //PHANTOMSTEEL: Main material for weapons
        if(material_index == 0){material_address = address(0);} 

        //IRONFLEECE: Main material for armors and helms
        if(material_index == 1){material_address = address(0);}

        //SILVERGLASS: Main material for accessories
        if(material_index == 2){material_address = address(0);}

        //AETHERLINK: Main material for consumables
        if(material_index == 3){material_address = address(0);}
    }

    function getCatalystAddress(uint256 catalyst_index) internal pure returns (address catalyst_address){
        //BLACK SPARKSTONE: Catalyst for weapons
        if(catalyst_index == 0){catalyst_address = address(0);}

        //WHITE SPARKSTONE: Catalyst for armors and helms
        if(catalyst_index == 1){catalyst_address = address(0);}

        //RED SPARKSTONE: Catalyst for accessories
        if(catalyst_index == 2){catalyst_address = address(0);}

        //BLUE SPARKSTONE: Catalyst for consumables
        if(catalyst_index == 3){catalyst_address = address(0);}
    }
 }
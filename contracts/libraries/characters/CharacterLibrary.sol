//SPDX-License-Identifier: MIT
/**
    @title Character URI Library
    @author Eman "Sgt"
    @notice: Reference for character Images and Names.
    Originally created for CHAINLINK HACKATHON FALL 2022
*/
pragma solidity =0.8.17;

import "../../libraries/StructLibrary.sol";

library CharacterLibrary {
    function getCharacter(uint32 character_class, uint32 mood) internal pure returns (character_image_and_name memory character){
        string memory image_url = "https://chainlink-rpg2022.infura-ipfs.io/ipfs/Qmah9GpdVg7vEvcEKaimymUmvb89utLTQwkYnbUdY8c6pv/";
        (string memory _class, string memory image_prefix) = getClass(character_class);
        character = character_image_and_name({
            name: _class,
            image: string.concat(image_url, image_prefix, _class, getMood(mood))
        });
    }

    function getClass(uint32 character_class) internal pure returns (string memory _class, string memory image_prefix){
        if(character_class == 0){_class = "Viking"; image_prefix = "0%20";}
        if(character_class == 1){_class = "Woodcutter"; image_prefix = "1%20";}
        if(character_class == 2){_class = "Troll"; image_prefix = "4%20";}
        if(character_class == 3){_class = "Mechanic"; image_prefix = "5%20";}
        if(character_class == 4){_class = "Amphibian"; image_prefix = "2%20";}
        if(character_class == 5){_class = "Graverobber"; image_prefix = "3%20";}
    }

    function getMood(uint32 mood) internal pure returns (string memory mood_tag){
        if(mood == 0){mood_tag = "/Amazed.png";}
        if(mood == 1){mood_tag = "/Angry.png";}
        if(mood == 2){mood_tag = "/Calm.png";}
        if(mood == 3){mood_tag = "/Furious.png";}
        if(mood == 4){mood_tag = "/Irritated.png";}
        if(mood == 5){mood_tag = "/Mocking.png";}
        if(mood == 6){mood_tag = "/Sad.png";}
        if(mood == 7){mood_tag = "/Scared.png";}
        if(mood == 8){mood_tag = "/Stunning.png";}
        if(mood == 9){mood_tag = "/Talking.png";}
        if(mood == 10){mood_tag = "/Thoughtful.png";}
        if(mood == 11){mood_tag = "/Upset.png";}
    }
}
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
    function getCharacter(uint64 character_class, uint32 mood) internal pure returns (character_image_and_name memory character){
        if(character_class == 0){character = getViking(mood);}
        if(character_class == 1){character = getWoodcutter(mood);}
        if(character_class == 2){character = getTroll(mood);}
        if(character_class == 3){character = getSteamEngineer(mood);}
        if(character_class == 4){character = getAmphibian(mood);}
        if(character_class == 5){character = getGraverobber(mood);}
    }

    function getViking(uint32 mood) internal pure returns (character_image_and_name memory character){
        string memory name = "Viking";
        string memory image;
        string memory baseURL = "https://chainlink-rpg2022.infura-ipfs.io/ipfs/Qmah9GpdVg7vEvcEKaimymUmvb89utLTQwkYnbUdY8c6pv/";
        if(mood == 0){image = "0%20Viking/Amazed.png";}
        if(mood == 1){image = "0%20Viking/Angry.png";}
        if(mood == 2){image = "0%20Viking/Calm.png";}
        if(mood == 3){image = "0%20Viking/Furious.png";}
        if(mood == 4){image = "0%20Viking/Irritated.png";}
        if(mood == 5){image = "0%20Viking/Mocking.png";}
        if(mood == 6){image = "0%20Viking/Sad.png";}
        if(mood == 7){image = "0%20Viking/Scared.png";}
        if(mood == 8){image = "0%20Viking/Stunning.png";}
        if(mood == 9){image = "0%20Viking/Talking.png";}
        if(mood == 10){image = "0%20Viking/Thoughtful.png";}
        if(mood == 11){image = "0%20Viking/Upset.png";}
        character = character_image_and_name({
            name: name,
            image: string.concat(baseURL, image)
        });
    }

    function getWoodcutter(uint32 mood) internal pure returns (character_image_and_name memory character){
        string memory name = "Woodcutter";
        string memory image;
        string memory baseURL = "https://chainlink-rpg2022.infura-ipfs.io/ipfs/Qmah9GpdVg7vEvcEKaimymUmvb89utLTQwkYnbUdY8c6pv/";
        if(mood == 0){image = "1%20Woodcutter/Amazed_1.png";}
        if(mood == 1){image = "1%20Woodcutter/Amity_1.png";}
        if(mood == 2){image = "1%20Woodcutter/Anger_1.png";}
        if(mood == 3){image = "1%20Woodcutter/Calm_1.png";}
        if(mood == 4){image = "1%20Woodcutter/Elated_1.png";}
        if(mood == 5){image = "1%20Woodcutter/Enjoyment_1.png";}
        if(mood == 6){image = "1%20Woodcutter/Irritation_1.png";}
        if(mood == 7){image = "1%20Woodcutter/Joyful_1.png";}
        if(mood == 8){image = "1%20Woodcutter/Sad_1.png";}
        if(mood == 9){image = "1%20Woodcutter/Stunning_1.png";}
        if(mood == 10){image = "1%20Woodcutter/Thoughtful_1.png";}
        if(mood == 11){image = "1%20Woodcutter/Upset_1.png";}
        character = character_image_and_name({
            name: name,
            image: string.concat(baseURL, image)
        });
    }

    function getTroll(uint32 mood) internal pure returns (character_image_and_name memory character){
        string memory name = "Troll";
        string memory image;
        string memory baseURL = "https://chainlink-rpg2022.infura-ipfs.io/ipfs/Qmah9GpdVg7vEvcEKaimymUmvb89utLTQwkYnbUdY8c6pv/";
        if(mood == 0){image = "4%20Troll/Amazed.png";}
        if(mood == 1){image = "4%20Troll/Angry.png";}
        if(mood == 2){image = "4%20Troll/Calm.png";}
        if(mood == 3){image = "4%20Troll/Furious.png";}
        if(mood == 4){image = "4%20Troll/Irritated.png";}
        if(mood == 5){image = "4%20Troll/Mocking.png";}
        if(mood == 6){image = "4%20Troll/Sad.png";}
        if(mood == 7){image = "4%20Troll/Scared.png";}
        if(mood == 8){image = "4%20Troll/Stunning.png";}
        if(mood == 9){image = "4%20Troll/Talking.png";}
        if(mood == 10){image = "4%20Troll/Thoughtful.png";}
        if(mood == 11){image = "4%20Troll/Upset.png";}
        character = character_image_and_name({
            name: name,
            image: string.concat(baseURL, image)
        });
    }

    function getSteamEngineer(uint32 mood) internal pure returns (character_image_and_name memory character){
        string memory name = "Steam Engineer";
        string memory image;
        string memory baseURL = "https://chainlink-rpg2022.infura-ipfs.io/ipfs/Qmah9GpdVg7vEvcEKaimymUmvb89utLTQwkYnbUdY8c6pv/";
        if(mood == 0){image = "5%20SteamMan/Amazed_3.png";}
        if(mood == 1){image = "5%20SteamMan/Amity_3.png";}
        if(mood == 2){image = "5%20SteamMan/Anger_3.png";}
        if(mood == 3){image = "5%20SteamMan/Calm_3.png";}
        if(mood == 4){image = "5%20SteamMan/Elated_3.png";}
        if(mood == 5){image = "5%20SteamMan/Enjoyment_3.png";}
        if(mood == 6){image = "5%20SteamMan/Irritation_3.png";}
        if(mood == 7){image = "5%20SteamMan/Joyful_3.png";}
        if(mood == 8){image = "5%20SteamMan/Sad_3.png";}
        if(mood == 9){image = "5%20SteamMan/Stunning_3.png";}
        if(mood == 10){image = "5%20SteamMan/Thoughtful_3.png";}
        if(mood == 11){image = "5%20SteamMan/Upset_3.png";}
        character = character_image_and_name({
            name: name,
            image: string.concat(baseURL, image)
        });
    }

    function getAmphibian(uint32 mood) internal pure returns (character_image_and_name memory character){
        string memory name = "Amphibian";
        string memory image;
        string memory baseURL = "https://chainlink-rpg2022.infura-ipfs.io/ipfs/Qmah9GpdVg7vEvcEKaimymUmvb89utLTQwkYnbUdY8c6pv/";
        if(mood == 0){image = "2%20Amphibian/Amazed.png";}
        if(mood == 1){image = "2%20Amphibian/Angry.png";}
        if(mood == 2){image = "2%20Amphibian/Calm.png";}
        if(mood == 3){image = "2%20Amphibian/Furious.png";}
        if(mood == 4){image = "2%20Amphibian/Irritated.png";}
        if(mood == 5){image = "2%20Amphibian/Mocking.png";}
        if(mood == 6){image = "2%20Amphibian/Sad.png";}
        if(mood == 7){image = "2%20Amphibian/Scared.png";}
        if(mood == 8){image = "2%20Amphibian/Stunning.png";}
        if(mood == 9){image = "2%20Amphibian/Talking.png";}
        if(mood == 10){image = "2%20Amphibian/Thoughtful.png";}
        if(mood == 11){image = "2%20Amphibian/Upset.png";}
        character = character_image_and_name({
            name: name,
            image: string.concat(baseURL, image)
        });
    }

    function getGraverobber(uint32 mood) internal pure returns (character_image_and_name memory character){
        string memory name = "Graverobber";
        string memory image;
        string memory baseURL = "https://chainlink-rpg2022.infura-ipfs.io/ipfs/Qmah9GpdVg7vEvcEKaimymUmvb89utLTQwkYnbUdY8c6pv/";
        if(mood == 0){image = "3%20GraveRobber/Amazed_2.png";}
        if(mood == 1){image = "3%20GraveRobber/Amity_2.png";}
        if(mood == 2){image = "3%20GraveRobber/Anger_2.png";}
        if(mood == 3){image = "3%20GraveRobber/Calm_2.png";}
        if(mood == 4){image = "3%20GraveRobber/Elated_2.png";}
        if(mood == 5){image = "3%20GraveRobber/Enjoyment_2.png";}
        if(mood == 6){image = "3%20GraveRobber/Irritation_2.png";}
        if(mood == 7){image = "3%20GraveRobber/Joyful_2.png";}
        if(mood == 8){image = "3%20GraveRobber/Sad_2.png";}
        if(mood == 9){image = "3%20GraveRobber/Stunning_2.png";}
        if(mood == 10){image = "3%20GraveRobber/Thoughtful_2.png";}
        if(mood == 11){image = "3%20GraveRobber/Upset_2.png";}
        character = character_image_and_name({
            name: name,
            image: string.concat(baseURL, image)
        });
    }
}
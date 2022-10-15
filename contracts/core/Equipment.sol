//SPDX-License-Identifier: MIT
/**
    @title Equipment
    @author Eman "Sgt"
    @notice: NFT Contract for items equippable to characters. Originally created for CHAINLINK HACKATHON FALL 2022
*/
pragma solidity =0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/Counters.sol";
import "../utils/BreakdownUint256.sol";
import "../libraries/StructLibrary.sol";
interface _RandomizationContract {
    function requestRandomWords(uint32 numWords) external returns (uint256 s_requestId);
    function randomNumber(uint256) external view returns(uint256[] memory);
}

interface _EquipmentLibrary {
    function getEquipmentDetails(uint256 _type, uint256 _rarity, uint256 _dominant_stat, uint256 extremity) external returns (equipment_details memory);
}

contract Equipments is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    _RandomizationContract randomizer;

    ///The beneficiary of the msg.value being sent to the contract for every mint request.
    address vrf_refunder;

    ///The randomization contract for generating random numbers for mint
    address randomizationContract;

    Counters.Counter private equipment_ids;

    ///Map out a user's address to its equipment crafting request (if any) {request_id, equipment_type, number_of_items}. If none, the request_id == 0.
    mapping (address => equipment_request) public request;

    ///Map out a specific equipment NFT id to its properties {equipment_type, dominant_stat, rarity, extremity}
    mapping (uint256 => equipment_properties) public equipment;

    ///Map out a specific equipment NFT id to its stats {atk, def, eva, ...}
    mapping (uint256 => equipment_stats) public stats;

    event EquipmentRequested(address indexed player_address, equipment_request request);
    event EquipmentMinted(uint256 indexed equipment_id, equipment_properties equipment_props);

    constructor(address _randomizationContract) ERC721("Characters", "CTRS") {
        vrf_refunder = msg.sender;
        randomizer = _RandomizationContract(_randomizationContract);
    }

    ///This function requests n random number/s from the VRF contract to be consumed with the mint.
    function requestEquipment(uint64 _equipment_type, uint32 items) public payable{
        ///Equipment/Items can only be weapon, armor, helm, accessory, and consumable. 0-4
        require(_equipment_type < 5, "EQPTS: Incorrect number for an equipment type.");
        
        ///Restrict number of mints to below 6 to avoid insufficient gas errors and accidental requests for very large number of mints.
        require(items > 0 && items < 6, "EQPTS: Can only request to mint 1 to 5 items at a time.");
        
        ///The MATIC being received is not payment for the NFT but rather to simply replenish the VRF subscribtion's funds and also serves as an effective anti-spam measure as well.
        require(msg.value == (items * 30000000 gwei), "EQPTS: Incorrect amount for equipment minting. Send exactly 0.03 MATIC per item requested.");
        
        ///EXTCALL to VRF contract. Set the caller's current equipment_request to the returned request_id by the VRF contract.
        request[msg.sender] = equipment_request({
            request_id: randomizer.requestRandomWords(items),
            equipment_type: _equipment_type,
            number_of_items: items
        });
        
        emit EquipmentRequested(msg.sender, request[msg.sender]);
    }

    ///Once the random numbers requested has been fulfilled in the VRF contract, this function can be called to complete the mint process.
    function mintEquipments() public {
        ///Check if the caller has enough materials for the mints.


        equipment_request memory _request = request[msg.sender];
        uint256[] memory randomNumberRequested = randomizer.randomNumber(_request.request_id);

        ///Check if there is a pending/fulfilled request previously made by the caller using requestEquipment().
        require(_request.request_id > 0, "EQPTS: No request to mint.");

        ///Verify if the random number request has been indeed fulfilled, revert if not.
        require(randomNumberRequested.length > 0, "EQPTS: Request is not yet fulfilled or invalid request id.");

        ///Loop thru the number of items requested to be minted.
        for(uint256 i=0; i < _request.number_of_items; i++){
            mintEquipment(randomNumberRequested[i], _request.equipment_type);
        }
        ///Reset the sender's request property values to 0
        request[msg.sender] = equipment_request({
            request_id: 0,
            equipment_type: 0,
            number_of_items: 0
        });
    }

    ///This internal function determines the equipment's properties using the random number requested
    function mintEquipment(uint256 randomNumberRequested, uint64 equipment_type) internal {
        (equipment_properties memory equipment_props, equipment_stats memory _equipment_stats) = getResult(randomNumberRequested, equipment_type);
        equipment_ids.increment();
        equipment[equipment_ids.current()] = equipment_props;
        stats[equipment_ids.current()] = _equipment_stats;
        _mint(msg.sender, equipment_ids.current());
        emit EquipmentMinted(equipment_ids.current(), equipment[equipment_ids.current()]);
    }

    function getResult(uint256 randomNumber, uint64 _equipment_type) internal pure returns (equipment_properties memory equipment_props, equipment_stats memory _equipment_stats){
        ///To save on LINK tokens for our VRF contract, we are breaking a single random word into 16 uint16s.
        ///The reason for this is we will need a lot of random numbers for a single equipment mint.
        ///It is given that the chainlink VRF generates verifiable, truly random numbers that it is safe to assume that breaking this
        ///truly random number poses no exploitable risk as far as the mint is concerned.
        ///However, there is a theoretical risk that the VRF generates a number with an extremely low number so that the first few uint16s would
        ///have their value at 0. In that case, it can be argued that it is simply not a blessing from the RNG Gods for the user/player.
        ///Still, our workaround if such thing occurs anyway is to start using the last numbers in the uint16s array which probably contains
        ///values greater than 0.
        uint16[] memory randomNumbers = BreakdownUint256.break256BitsIntegerIntoBytesArrayOf16Bits(randomNumber);

        ///Get the rarity of the equipment using the last item in the uint16[]. The rarity also determines how much stat points the equipment has.
        ///The rarer the item, the higher the stat points it holds.
        (uint64 _rarity, uint32 stat_sum) = getRarity(randomNumbers[16]);

        ///Get the stat allocation of the equipment using the next 8 items from the last in the uint16[]. The stat points determined from
        ///rarity of the item from the last function is allocated this way.
        uint16[8] memory random_stats = [randomNumbers[15], randomNumbers[14], randomNumbers[13], randomNumbers[12], randomNumbers[11], randomNumbers[10], randomNumbers[9], randomNumbers[8]];
        
        ///Here we check what stat {atk, def, eva, ... } the equipment has the highest allocation. This determines the item's dominant stat.
        ///In case of weapons, it determine's the weapon's type (hammer, dagger, bombard,...)
        ///Also, we check the extremity of the item's dominant stat (minor, good, great, intense,...)
        uint64 _dominant_stat; uint64 _extremity;
        (_equipment_stats, _dominant_stat, _extremity) = getStats(random_stats, stat_sum);
        equipment_props = equipment_properties({
            equipment_type: _equipment_type,
            rarity: _rarity,
            dominant_stat: _dominant_stat,
            extremity: _extremity
        });
    }

    function getRarity(uint16 number) internal pure returns (uint64 rarity, uint32 stat_sum){
        uint256 roll_value = number % 1000;
        if(roll_value > 994){rarity = 4; stat_sum = 100;} //.05%
        if(roll_value > 989 && roll_value < 995){rarity = 3; stat_sum = 50;} //.1%
        if(roll_value > 959 && roll_value < 990){rarity = 2; stat_sum = 30;} //4%
        if(roll_value > 799 && roll_value < 960){rarity = 1; stat_sum = 20;} //20%
        if(roll_value >= 0 && roll_value < 800){rarity = 0; stat_sum = 10;} //75%
    }

    function getStats(uint16[8] memory random_stats, uint32 stat_sum) internal pure returns (equipment_stats memory _equipment_stats, uint64 dominant_stat, uint64 extremity){
        uint32 total;
        uint32[8] memory roll_values;
        uint32[8] memory _stats;
        for(uint256 i = 0; i < random_stats.length; i++){
            uint32 roll_value = random_stats[i] % 1000;
            roll_values[i] = roll_value;
            total += roll_value;
        }
        for(uint256 i = 0; i < roll_values.length; i++){
            _stats[i] = (roll_values[i] * stat_sum) / total;
        }

        _equipment_stats = equipment_stats({
            atk: _stats[0],
            def: _stats[1],
            eva: _stats[2],
            hp: _stats[3],
            pen: _stats[4],
            crit: _stats[5],
            luck: _stats[6],
            energy_regen: _stats[7]
        });

        dominant_stat = getDominantStat(roll_values);
        extremity = getExtremity(roll_values[dominant_stat], total);
    }

    function getDominantStat(uint32[8] memory roll_values) internal pure returns (uint64 dominant_stat){
        uint256[8] memory stat_index = [uint256(0),1,2,3,4,5,6,7];
        uint256 l = roll_values.length;
        for (uint256 i = 0; i < l; i++) {
            for (uint256 j = i + 1; j < l; j++) {
                if (roll_values[i] < roll_values[j]) {
                    uint32 temp = roll_values[i];
                    uint256 temp2 = stat_index[i];
                    roll_values[i] = roll_values[j];
                    stat_index[i] = stat_index[j];
                    roll_values[j] = temp;
                    stat_index[j] = temp2;
                }
            }
        }
        dominant_stat = uint64(stat_index[0]);
    }

    function getExtremity(uint32 dominant_stat_value, uint32 total) internal pure returns (uint64 extremity){
        uint32 percentage_allocation = (dominant_stat_value * 1000) / total;
        if(percentage_allocation == 125){extremity = 0;}
        if(percentage_allocation > 124 && percentage_allocation < 250){extremity = 1;}
        if(percentage_allocation > 249 && percentage_allocation < 375){extremity = 2;}
        if(percentage_allocation > 374 && percentage_allocation < 500){extremity = 3;}
        if(percentage_allocation > 499 && percentage_allocation < 625){extremity = 4;}
        if(percentage_allocation > 624 && percentage_allocation < 750){extremity = 6;}
        if(percentage_allocation > 749 && percentage_allocation < 875){extremity = 7;}
        if(percentage_allocation > 874 && percentage_allocation < 999){extremity = 8;}
    }

    function isOwner(address _owner, uint256 _equipment) public view returns (bool){
        return super._isApprovedOrOwner(_owner, _equipment);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function withdraw() public onlyOwner{
        (bool succeed, ) = vrf_refunder.call{value: address(this).balance}("");
        require(succeed, "Failed to withdraw matics.");
    }
}


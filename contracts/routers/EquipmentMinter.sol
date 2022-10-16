///SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/BreakdownUint256.sol";
import "../libraries/equipment/CraftingRecipes.sol";
import "../libraries/materials/MaterialsAddresses.sol";
import "../libraries/StructLibrary.sol";

interface _RandomizationContract {
    function requestRandomWords(uint32 numWords, address user) external returns (uint256 requestId);
    function getRequestStatus(uint256 _requestId) external view returns(bool fulfilled, uint256[] memory randomWords);
}

interface _EquipmentLibrary {
    function getEquipmentDetails(uint256 _type, uint256 _rarity, uint256 _dominant_stat, uint256 extremity) external returns (equipment_details memory);
}

interface _Equipments {
    function _mintEquipment(equipment_properties memory equipment_props, equipment_stats memory _equipment_stats) external;
}

contract EquipmentMinter is Ownable{
    ///The randomization contract for generating random numbers for mint
    _RandomizationContract randomizer;
    _Equipments equipmentsNft;

    ///The beneficiary of the msg.value being sent to the contract for every mint request.
    address vrf_refunder;

    ///Map out a user's address to its equipment crafting request (if any) {request_id, equipment_type, number_of_items}. If none, the request_id == 0.
    mapping (address => equipment_request) public request;
    
    event EquipmentRequested(address indexed player_address, equipment_request request);
    constructor(address equipmentsNftAddress){
        equipmentsNft = _Equipments(equipmentsNftAddress);
        vrf_refunder = msg.sender;
    }

    ///@notice This function requests n random number/s from the VRF contract to be consumed with the mint.
    function requestEquipment(uint64 _equipment_type, uint32 item_count) public payable{
        ///We can only allow one request per address at a time. A request shall be completed (minted the equipment) to be able request another one.
        equipment_request memory _request = request[msg.sender];
        require(_request.request_id == 0, "EQPTS: There is a request pending mint.");

        ///Equipment/Items can only be weapon, armor, helm, accessory, and consumable. 0-4
        require(_equipment_type < 5, "EQPTS: Incorrect number for an equipment type.");
        
        ///Restrict number of mints to below 6 to avoid insufficient gas errors and accidental requests for very large number of mints.
        require(item_count > 0 && item_count < 6, "EQPTS: Can only request to mint 1 to 5 items at a time.");
        
        ///The MATIC being received is not payment for the NFT but rather to simply replenish the VRF subscribtion's funds and also serves as an effective anti-spam measure as well.
        require(msg.value == (item_count * 30000000 gwei), "EQPTS: Incorrect amount for equipment minting. Send exactly 0.03 MATIC per item requested.");
        
        ///EXTCALL to VRF contract. Set the caller's current equipment_request to the returned request_id by the VRF contract.
        request[msg.sender] = equipment_request({
            request_id: randomizer.requestRandomWords(item_count, msg.sender),
            equipment_type: _equipment_type,
            number_of_items: item_count
        });
        
        emit EquipmentRequested(msg.sender, request[msg.sender]);
    }

    ///@notice This function will get the recipe for the equipment to be crafted and will check the token balances of the user for 
    ///each material required. If enough balance is determined, proceed to burn the amounts from the user's token balances.
    function getEquipmentRequirements(uint256 equipment_type, uint256 item_count) internal returns (bool enough){
        ///We will assume at first that the user has enough balances for the materials required. Then we will check each materials
        ///one by one. If we determine that the user in fact DOES NOT have enough balance in any one of the materials, then we will
        ///set this to false and the transaction will revert.
        enough = true;

        ///We determine the recipe by equipment type.
        item_recipe memory recipe = CraftingRecipes.getRecipe(equipment_type);

        ///Determine the total amounts required. The `getRecipe()` from the library CraftingRecipes returns the amount required for
        ///only one piece of equipment to be crafted. So we multiply the respective amounts by the number of equipment the user has
        ///chosen to mint.
        recipe.main_material_amount = recipe.main_material_amount * item_count;
        recipe.indirect_material_amount = recipe.indirect_material_amount * item_count;
        recipe.catalyst_amount = recipe.catalyst_amount * item_count;

        ///We fetch the balances of the user for the required materials and also the corresponding contract instance.
        (uint256 main_material_balance, ERC20Burnable main_material_contract) = checkMaterialBalance(recipe.main_material);
        (uint256 indirect_material_balance, ERC20Burnable indirect_material_contract) = checkMaterialBalance(recipe.indirect_material);
        (uint256 catalyst_balance, ERC20Burnable catalyst_contract) = checkCatalystBalance(recipe.catalyst);

        ///We compare the user's token balances with the required amounts.
        if(main_material_balance < recipe.main_material_amount){enough = false;}
        if(indirect_material_balance < recipe.indirect_material_amount){enough = false;}
        if(catalyst_balance < recipe.catalyst_amount){enough = false;}

        ///If the user's token balances are indeed enough for the required materials, we then burn it from the user's balance.
        ///Make sure to prompt the user to set enough token allowances before initiating an equipment request transaction.
        if(enough == true){
            main_material_contract.burnFrom(msg.sender, recipe.main_material_amount);
            indirect_material_contract.burnFrom(msg.sender, recipe.indirect_material_amount);
            catalyst_contract.burnFrom(msg.sender, recipe.catalyst_amount);
        }
    }

    ///@notice This function checks the user's balance and returns the corresponding token contract instance.
    function checkMaterialBalance(uint256 material_index) internal view returns (uint256 balance, ERC20Burnable material_contract){
            address material_address = MaterialsAddresses.getMaterialAddress(material_index);
            material_contract = ERC20Burnable(material_address);
            balance = material_contract.balanceOf(msg.sender);
    }

    ///@notice This function checks the user's balance and returns the corresponding token contract instance.
    function checkCatalystBalance(uint256 catalyst_index) internal view returns (uint256 balance, ERC20Burnable catalyst_contract){
        address catalyst_address = MaterialsAddresses.getCatalystAddress(catalyst_index);
        catalyst_contract = ERC20Burnable(catalyst_address);
        balance = catalyst_contract.balanceOf(msg.sender);
    }

    ///Once the random numbers requested has been fulfilled in the VRF contract, this function can be called to complete the mint process.
    function mintEquipments() public {
        equipment_request memory _request = request[msg.sender];
        (bool fulfilled, uint256[] memory randomNumberRequested) = randomizer.getRequestStatus(_request.request_id);

        ///Check if there is a pending/fulfilled request previously made by the caller using requestEquipment().
        require(_request.request_id > 0, "EQPTS: No request to mint.");

        ///Verify if the random number request has been indeed fulfilled, revert if not.
        require(fulfilled, "EQPTS: Request is not yet fulfilled or invalid request id.");

        ///Burn the materials from the user's balance.
        bool enough = getEquipmentRequirements(_request.equipment_type, _request.number_of_items);
        require(enough, "EQPTS: Not enough materials for this crafting transaction.");

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


    function mintEquipment(uint256 randomNumberRequested, uint64 equipment_type) internal {
        (equipment_properties memory equipment_props, equipment_stats memory _equipment_stats) = getResult(randomNumberRequested, equipment_type);
        equipmentsNft._mintEquipment(equipment_props, _equipment_stats);
    }

    function getResult(uint256 randomNumber, uint64 _equipment_type) internal pure returns (equipment_properties memory equipment_props, equipment_stats memory _equipment_stats){
        ///To save on LINK tokens for our VRF contract, we are breaking a single random word into 16 uint16s.
        ///The reason for this is we will need a lot(9) of random numbers for a single equipment mint.
        ///It is given that the chainlink VRF generates verifiable, truly random numbers that it is safe to assume that breaking this
        ///truly random number poses no exploitable risk as far as the mint is concerned.
        ///However, there is a theoretical risk that the VRF generates a number with an extremely low number so that the first few uint16s would
        ///have their value at 0. In that case, it can be argued that it is simply not a blessing from the RNG Gods for the user/player.
        ///Still, our workaround if such thing occurs anyway is to start using the last numbers in the uint16s array which probably contains
        ///values greater than 0.
        uint16[] memory randomNumbers = BreakdownUint256.break256BitsIntegerIntoBytesArrayOf16Bits(randomNumber);

        ///Get the rarity of the equipment using the last item in the uint16[]. The rarity also determines how much stat points the equipment has.
        ///The rarer the item, the higher the stat points it holds.
        (uint64 _rarity, uint32 stat_sum) = getRarity(randomNumbers[15]);

        ///Get the stat allocation of the equipment using the next 8 items from the last in the uint16[]. The stat points determined from
        ///rarity of the item from the last function is allocated this way.
        uint16[8] memory random_stats = [randomNumbers[14], randomNumbers[13], randomNumbers[12], randomNumbers[11], randomNumbers[10], randomNumbers[9], randomNumbers[8], randomNumbers[7]];
        
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
        if(roll_value > 989 && roll_value < 995){rarity = 3; stat_sum = 60;} //.1%
        if(roll_value > 959 && roll_value < 990){rarity = 2; stat_sum = 40;} //4%
        if(roll_value > 799 && roll_value < 960){rarity = 1; stat_sum = 25;} //20%
        if(roll_value >= 0 && roll_value < 800){rarity = 0; stat_sum = 15;} //75%
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

    ///@notice Admin Functions
    function setRandomizationContract(address _vrfContract) public onlyOwner {
        randomizer = _RandomizationContract(_vrfContract);
    }

    function withdraw() public onlyOwner{
        (bool succeed, ) = vrf_refunder.call{value: address(this).balance}("");
        require(succeed, "Failed to withdraw matics.");
    }
}
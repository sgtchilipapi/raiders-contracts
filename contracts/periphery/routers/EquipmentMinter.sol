///SPDX-License-Identifier:MIT
/**
    @title EquipmentMinter
    @author Eman @SgtChiliPapi
    @notice: This contract serves as the router/minter for the Equipment NFT. It communicates with the VRF contract,
    performs the necessary calculations to determine the equipment's properties and stats and ultimately calls the mint 
    function of the NFT contract with the calculated results as arguments. Only this contract can call the NFT's mint function
    and only one router at a time can be set in the NFT contract as well.
    Originally created for CHAINLINK HACKATHON FALL 2022
*/
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../utils/BreakdownUint256.sol";
import "../libraries/equipment/CraftingRecipes.sol";
import "../libraries/structs/GlobalStructs.sol";
import "../libraries/structs/CharacterStructs.sol";

interface _RandomizationContract {
    function requestRandomWords(address user, uint32 numWords, bool experimental) external returns (uint256 requestId);
    function getRequestStatus(uint256 _requestId) external view returns(bool fulfilled, uint256[] memory randomWords);
}

interface _EquipmentLibrary {
    function getEquipmentDetails(uint256 _type, uint256 _rarity, uint256 _dominant_stat, uint256 extremity) external returns (equipment_details memory);
}

interface _Equipments {
    function _mintEquipment(address user, equipment_properties memory equipment_props, battle_stats memory _equipment_stats) external;
}

interface _Characters {
    function isOwner(address _owner, uint256 _character) external view returns (bool);
    function character(uint256 _character_id) external view returns (character_properties memory);
}

interface _EnerLink {
    function mint(address to, uint256 amount) external;
}

contract EquipmentMinter is Ownable, Pausable{
    ///The randomization contract for generating random numbers for mint
    _RandomizationContract private randomizer;
    _Characters private characters;
    _EnerLink private enerlink;
    address private vrfContract;

    ///The core: Equipment NFT contract deployment.
    _Equipments equipmentsNft;

    ///The beneficiary of the msg.value being sent to the contract for every mint request.
    address private vrf_refunder;

    ///Map out a user's address to its equipment crafting request (if any) {request_id, equipment_type, number_of_items}. If none, the request_id == 0.
    mapping (address => equipment_request) public request;

    ///The msg.value required to mint to prevent spam and deplete VRF funds.
    ///Currently unset (0) for judging purposes as stated in the hackathon rules.
    uint256 public mint_fee;

    ///mapping to restrict free mints to players/characters
    //character => equipment_type => bool
    mapping(uint256 => mapping(uint256 => bool)) public character_minted_free;

    ///Arrays of addresses for the materials and catalyst tokens
    address[4] private materials_addresses;
    address[4] private catalysts_addresses; 
    
    event EquipmentRequested(address indexed player_address, equipment_request request);
    constructor(address equipmentsNftAddress, address charactersAddress, address enerlinkAddress, address[4] memory materials, address[4] memory catalysts){
        equipmentsNft = _Equipments(equipmentsNftAddress);
        characters = _Characters(charactersAddress);
        enerlink = _EnerLink(enerlinkAddress);
        materials_addresses = materials;
        catalysts_addresses = catalysts;
        vrf_refunder = msg.sender;
    }

    ///@notice This function requests n random number/s from the VRF contract to be consumed with the mint.
    function requestEquipment(uint64 _equipment_type , uint256 item_count) public payable whenNotPaused{
        ///We can only allow one request per address at a time. A request shall be completed (minted the equipment) to be able request another one.
        equipment_request memory _request = request[msg.sender];
        require(_request.request_id == 0, "eMNTR: There is a request pending mint.");

        ///Equipment/Items can only be weapon, armor, helm, accessory, and consumable. 0-4
        require(_equipment_type < 5, "eMNTR: Incorrect number for an equipment type.");
        
        ///The MATIC being received is not payment for the NFT but rather to simply replenish the VRF subscribtion's funds and also serves as an effective anti-spam measure as well.
        ///Restrict number of mints to below 4 to avoid insufficient gas errors and accidental requests for very large number of mints.
        require(item_count > 0 && item_count < 4, "eMNTR: Can only request to mint 1 to 3 items at a time.");
        require(msg.value >= (item_count * mint_fee), "eMNTR: Incorrect amount for equipment minting. Send exactly 0.01 MATIC per item requested.");
        
        ///Burn the materials from the user's balance.
        bool enough = getEquipmentRequirements(_equipment_type, item_count);
        require(enough, "eMNTR: Not enough materials for this crafting transaction.");
        
        ///@notice EXTCALL to VRF contract. Set the caller's current equipment_request to the returned request_id by the VRF contract.
        ///The bool argument here notifies the vrf contract that the request being sent is NOT experimental.
        request[msg.sender] = equipment_request({
            request_id: randomizer.requestRandomWords(msg.sender, uint32(item_count),  false),
            equipment_type: _equipment_type,
            number_of_items: uint32(item_count),
            time_requested: block.timestamp,
            free: false
        });
        
        emit EquipmentRequested(msg.sender, request[msg.sender]);
    }

    ///@notice This function is flagged as EXPERIMENTAL. This invokes a request to the VRF of random numbers which are when
    ///fulfilled, the VRF (automatically) mints the NFT within the same transaction as the fulfillment.
    ///This function requests n random number/s from the VRF contract to be consumed with the mint.
    function requestEquipmentExperimental(uint64 _equipment_type /**, uint32 item_count */) public payable whenNotPaused{
        ///We can only allow one request per address at a time. A request shall be completed (minted the equipment) to be able request another one.
        equipment_request memory _request = request[msg.sender];
        require(_request.request_id == 0, "eMNTR: There is a request pending mint.");

        ///Equipment/Items can only be weapon, armor, helm, accessory, and consumable. 0-4
        require(_equipment_type < 5, "eMNTR: Incorrect number for an equipment type.");
        
        ///The MATIC being received is not payment for the NFT but rather to simply replenish the VRF subscribtion's funds and also serves as an effective anti-spam measure as well.
        ///Using a constant 1 as n or number of equipments to be minted so as to stay well below the gas Limit of
        ///the VRF's fulfillRandomWords() as it is also responsible for triggering the actual minting.
        ///In case we can have make it clear that minting multiple equipments is safe, we can allow multiple mints by specifying the 
        ///desired number of mints per transaction.
            ///Restrict number of mints to below 4 to avoid insufficient gas errors and requests for very large number of mints.
            // require(item_count > 0 && item_count < 4, "eMNTR: Can only request to mint 1 to 3 items at a time.");
        require(msg.value >= (/**item_count */ 1 * mint_fee), "eMNTR: Incorrect amount for equipment minting. Send exactly 0.01 MATIC per item requested.");
        
        ///Burn the materials from the user's balance.
        ///Using a constant 1. See above reason on line 57 (unwrapped).
        bool enough = getEquipmentRequirements(_equipment_type, 1 /**item_count */);
        require(enough, "eMNTR: Not enough materials for this crafting transaction.");
        
        ///@notice EXTCALL to VRF contract. Set the caller's current equipment_request to the returned request_id by the VRF contract.
        ///Using a constant 1. See above reason on line 57 (unwrapped).
        ///The bool argument here notifies the vrf contract that the request being sent is experimental.
        request[msg.sender] = equipment_request({
            request_id: randomizer.requestRandomWords(/**item_count */msg.sender, 1, true),
            equipment_type: _equipment_type,
            number_of_items: 1,
            time_requested: block.timestamp,
            free: false
        });
        
        emit EquipmentRequested(msg.sender, request[msg.sender]);
    }

    ///@notice This is to mint equipments for free to give out starting characters a minting experience. The free mint will always
    ///give out common equipment.
    function requestEquipmentFree(uint256 character_id, uint64 _equipment_type /**, uint32 item_count */) public payable whenNotPaused{
        ///We can only allow one request per address at a time. A request shall be completed (minted the equipment) to be able request another one.
        equipment_request memory _request = request[msg.sender];
        require(_request.request_id == 0, "eMNTR: There is a request pending mint.");

        ///Equipment/Items can only be weapon, armor, helm, accessory, and consumable. 0-4
        require(_equipment_type < 5, "eMNTR: invalid eqpt type.");

        ///Require 0.01 msg.value
        require(msg.value >= (/**item_count */ 1 * mint_fee), "eMNTR: send 0.01 matic");

        ///Allow only one free mint per character per equipment
        require(!character_minted_free[character_id][_equipment_type], "eMNTR: character already minted.");

        ///Allow only characters with exp greater than 200
        require(characters.character(character_id).exp > 200, "eMNTR: insuf char exp.");

        ///Check ownership
        require(characters.isOwner(msg.sender, character_id), "eMNTR: character not owned.");

        ///Update the character and user mapping to free mints immediately after checking
        character_minted_free[character_id][_equipment_type] = true;

        ///@notice EXTCALL to VRF contract. Set the caller's current equipment_request to the returned request_id by the VRF contract.
        ///Using a constant 1. See above reason on line 57 (unwrapped).
        ///The first bool argument here notifies the vrf contract that the request being sent is experimental.
        request[msg.sender] = equipment_request({
            request_id: randomizer.requestRandomWords(/**item_count */ msg.sender, 1, false),
            equipment_type: _equipment_type,
            number_of_items: 1,
            time_requested: block.timestamp,
            free: true
        });
        
        emit EquipmentRequested(msg.sender, request[msg.sender]);
    }

    ///@notice This function will reset the senders request. In case requests dont get fulfilled by the VRF within an hour.
    function cancelRequestExperimental() public {
        equipment_request memory _request = request[msg.sender];
        (bool fulfilled,) = randomizer.getRequestStatus(_request.request_id);
        require(_request.request_id > 0, "eMNTR: Cannot cancel non-existing requests.");
        require((block.timestamp - _request.time_requested) > 3600, "eMNTR: Cannot cancel requests that havent lapsed 1 hour from time requested.");
        require(!fulfilled, "eMNTR: Cannot cancel requests that have already been fulfilled.");
        request[msg.sender] = equipment_request({
            request_id: 0,
            equipment_type: 0,
            number_of_items: 0,
            time_requested: block.timestamp,
            free: false
        });
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
            address material_address = materials_addresses[material_index];
            material_contract = ERC20Burnable(material_address);
            balance = material_contract.balanceOf(msg.sender);
    }

    ///@notice This function checks the user's balance and returns the corresponding token contract instance.
    function checkCatalystBalance(uint256 catalyst_index) internal view returns (uint256 balance, ERC20Burnable catalyst_contract){
        address catalyst_address = catalysts_addresses[catalyst_index];
        catalyst_contract = ERC20Burnable(catalyst_address);
        balance = catalyst_contract.balanceOf(msg.sender);
    }

    ///Once the random numbers requested has been fulfilled in the VRF contract, this function shall be called by the user
    ///to complete the mint process.
    function mintEquipments() public{
        equipment_request memory _request = request[msg.sender];

        ///Check if there is a pending/fulfilled request previously made by the caller using requestEquipment().
        require(_request.request_id > 0, "eMNTR: No request to mint.");

        ///Fetch the request status from the VRF contract.
        (bool fulfilled, uint256[] memory randomNumberRequested) = randomizer.getRequestStatus(_request.request_id);

        ///Verify if the random number request has been indeed fulfilled, revert if not.
        require(fulfilled, "eMNTR: Request is not yet fulfilled or invalid request id.");

        ///Loop thru the number of items requested to be minted.
        for(uint256 i=0; i < _request.number_of_items; i++){
            mintEquipment(msg.sender, randomNumberRequested[i], _request.equipment_type, _request.free);
        }
        ///Reset the sender's request property values to 0
        request[msg.sender] = equipment_request({
            request_id: 0,
            equipment_type: 0,
            number_of_items: 0,
            time_requested: block.timestamp,
            free: false
        });
    }

    ///@notice This function is flagged as EXPERIMENTAL. There is a risk for a loss of material tokens if the call to this
    ///function by the VRF reverts.
    ///Once the random numbers requested has been fulfilled in the VRF contract, this function is called by the VRF contract
    ///to complete the mint process.
    function mintEquipmentsExperimental(address user, uint256[] memory randomNumberRequested) public onlyVRF{
        equipment_request memory _request = request[user];
        ///@notice Removing the immediate following external SLOAD since the VRF already knows the randomNumberRequested, 
        ///we simply pass it from the VRF's external call to this function
            // (/** bool fulfilled */, uint256[] memory randomNumberRequested) = randomizer.getRequestStatus(_request.request_id);

        ///@notice We are removing the immediate following requirements since we have shifted the minting responsibility to the VRF.
        ///When the fulfillRandomWords() is executed, there is no more need to check if the request has been fulfilled.
            ///Check if there is a pending/fulfilled request previously made by the caller using requestEquipment().
            // require(_request.request_id > 0, "eMNTR: No request to mint.");

            ///Verify if the random number request has been indeed fulfilled, revert if not.
            // require(fulfilled, "eMNTR: Request is not yet fulfilled or invalid request id.");

        ///Loop thru the number of items requested to be minted.
        for(uint256 i=0; i < _request.number_of_items; i++){
            mintEquipment(user, randomNumberRequested[i], _request.equipment_type, _request.free);
        }
        ///Reset the sender's request property values to 0
        request[user] = equipment_request({
            request_id: 0,
            equipment_type: 0,
            number_of_items: 0,
            time_requested: block.timestamp,
            free: false
        });
    }

    ///@notice This includes external call to the Equipment NFT Contract or the EnerLink Contract to actually mint the tokens.
    function mintEquipment(address user, uint256 randomNumberRequested, uint64 equipment_type, bool _free) internal {
        ///If the item being minted is a consumable / EnerLink token
        if(equipment_type == 4){
            uint256 consumable_minted = (randomNumberRequested % 3) + 1;
            enerlink.mint(user, consumable_minted * 1 ether);
        }
        ///If the item being minted is an equipment
        if(equipment_type != 4){
            (equipment_properties memory equipment_props, battle_stats memory _equipment_stats) = getResult(randomNumberRequested, equipment_type, _free);
            equipmentsNft._mintEquipment(user, equipment_props, _equipment_stats);
        }
    }

    function getResult(uint256 randomNumber, uint64 _equipment_type, bool _free) internal pure returns (equipment_properties memory equipment_props, battle_stats memory _equipment_stats){
        ///To save on LINK tokens for our VRF contract, we are breaking a single random word into 16 uint16s.
        ///The reason for this is we will need a lot(9) of random numbers for a single equipment mint.
        ///It is given that the chainlink VRF generates verifiable, truly random numbers that it is safe to assume that breaking this
        ///truly random number poses no exploitable risk as far as the mint is concerned.
        ///However, there is a theoretical risk that the VRF generates a number with an extremely low number so that the first few uint16s would
        ///have their value at 0. In that case, it can be argued that it simply is not a blessing from the RNG Gods for the user.
        ///Still, our workaround if such thing occurs anyway is to start using the last numbers in the uint16s array which probably contains
        ///values greater than 0.
        uint16[] memory randomNumbers = BreakdownUint256.break256BitsIntegerIntoBytesArrayOf16Bits(randomNumber);

        ///Get the rarity of the equipment using the last item in the uint16[]. The rarity also determines how much stat points the equipment has.
        ///The rarer the item, the higher the stat points it holds.
        (uint64 _rarity, uint256 stat_sum) = getRarity(randomNumbers[15]);

        ///If the mint request is a free one, limit the rarity to the lowest tier
        if(_free){_rarity = 0;}

        ///Get the stat allocation of the equipment using the next 8 items from the last in the uint16[]. The stat points determined from
        ///rarity of the item from the getRarity() is allocated this way.
        uint16[8] memory random_stats = [randomNumbers[14], randomNumbers[13], randomNumbers[12], randomNumbers[11], randomNumbers[10], randomNumbers[9], randomNumbers[8], randomNumbers[7]];
        
        ///Here we check what stat {atk, def, eva, ... } the equipment has the highest allocation. This determines the item's dominant stat.
        ///In case of weapons, it determine's the weapon's type (hammer, dagger, bombard,...)
        ///Also, we check the extremity of the item's dominant stat (weak, minor, good, great, intense,...)
        uint64 _dominant_stat; uint64 _extremity;
        (_equipment_stats, _dominant_stat, _extremity) = getStats(random_stats, stat_sum, _equipment_type);
        equipment_props = equipment_properties({
            equipment_type: _equipment_type,
            rarity: _rarity,
            dominant_stat: _dominant_stat,
            extremity: _extremity
        });
    }

    function getRarity(uint16 number) internal pure returns (uint64 rarity, uint256 stat_sum){
        uint256 roll_value = number % 1000;
        if(roll_value > 994){rarity = 4; stat_sum = 100;} //.5% chance. If you ever get one, you might as well try the lottery.
        if(roll_value > 984 && roll_value <= 994){rarity = 3; stat_sum = 60;} //1%
        if(roll_value > 944 && roll_value <= 984){rarity = 2; stat_sum = 40;} //4%
        if(roll_value > 744 && roll_value <= 944){rarity = 1; stat_sum = 25;} //20%
        if(roll_value >= 0 && roll_value <= 748){rarity = 0; stat_sum = 15;} //75%
    }

    function getStats(uint16[8] memory random_stats, uint256 stat_sum, uint256 _equipment_type) internal pure returns (battle_stats memory _equipment_stats, uint64 dominant_stat, uint64 extremity){
        uint256 total_roll_value;
        uint256 dominant_roll_value;
        uint256[8] memory roll_values;
        uint256[8] memory _stats;
        for(uint256 i = 0; i < random_stats.length; i++){
            uint256 roll_value = random_stats[i] % 1000;
            roll_values[i] = roll_value;
            total_roll_value += roll_values[i];
        }
        for(uint256 i = 0; i < roll_values.length; i++){
            _stats[i] = (roll_values[i] * stat_sum) / total_roll_value;
        }

        (uint256 base_stat_index, uint256 base_stat_value) = getBaseStat(_equipment_type, stat_sum);
        _stats[base_stat_index] += base_stat_value;

        _equipment_stats = battle_stats({
            atk: uint32(_stats[0]),
            def: uint32(_stats[1]),
            eva: uint32(_stats[2]),
            hp: uint32(_stats[3]),
            pen: uint32(_stats[4]),
            crit: uint32(_stats[5]),
            luck: uint32(_stats[6]),
            energy_restoration: uint32(_stats[7])
        });

        (dominant_stat, dominant_roll_value)  = getDominantStat(roll_values);
        extremity = getExtremity(dominant_roll_value, total_roll_value, stat_sum);
    }

    ///@notice This function calculates the equipment's base stat value. We determine the type of the equipment first to know what
    ///particular stat it has as its primary stat. Then we calculate for its value using the stat_sum that is derived from the 
    ///equipment's rarity. 
    
    ///For example, a weapon has ATK as its primary stat. Then we calculate for the value using the stat_sum.
    function getBaseStat(uint256 _equipment_type, uint256 stat_sum) internal pure returns (uint256 stat_index, uint256 stat_value){
        if(_equipment_type == 0){
            stat_index = 0;
            ///@notice We have arbitrarily set the MAX stat effect of any equipment here at 300 for simplicity purposes.
            ///If further game balance should be desired, this library should be revised. We have also added a +50 bonus
            ///multiplier & denominator to all kinds of equipment to dilute the effects of the rarity a bit to achieve reasonable game balance.
            stat_value = (300 * (stat_sum + 50)) / 150;
        }
        if(_equipment_type == 1){
            stat_index = 1;
            stat_value = ((225 * (stat_sum + 50)) / 150) / 2;
        }
        if(_equipment_type == 2){
            stat_index = 1;
            stat_value = ((75 * (stat_sum + 50)) / 150) / 2;
        }
        if(_equipment_type == 3){
            stat_index = 2;
            stat_value = ((300 * (stat_sum + 50)) / 150) / 2;
        }
    }

    function getDominantStat(uint256[8] memory roll_values) internal pure returns (uint64 dominant_stat, uint256 dominant_roll_value){
        uint256[8] memory stat_index = [uint256(0),1,2,3,4,5,6,7];
        uint256 l = roll_values.length;
        for (uint256 i = 0; i < l; i++) {
            for (uint256 j = i + 1; j < l; j++) {
                if (roll_values[i] < roll_values[j]) {
                    uint256 temp = roll_values[i];
                    uint256 temp2 = stat_index[i];
                    roll_values[i] = roll_values[j];
                    stat_index[i] = stat_index[j];
                    roll_values[j] = temp;
                    stat_index[j] = temp2;
                }
            }
        }
        dominant_stat = uint64(stat_index[0]);
        dominant_roll_value = roll_values[0];
    }

    function getExtremity(uint256 dominant_roll_value, uint256 total_roll_value, uint256 stat_sum) internal pure returns (uint64 extremity){
        uint256 stat_value = (dominant_roll_value * stat_sum) / total_roll_value;
        if(stat_value > 5 && stat_value <= 10){extremity = 1;} //good
        if(stat_value > 10 && stat_value <= 15){extremity = 2;} //great
        if(stat_value > 15 && stat_value <= 20){extremity = 3;} //intense
        if(stat_value > 20 && stat_value <= 30){extremity = 4;} //extraordinary
        if(stat_value > 30 && stat_value <= 45){extremity = 5;} //ethereal
        if(stat_value > 45 && stat_value <= 65){extremity = 6;} //astronomical
        if(stat_value > 65){extremity = 7;} //divine
    }

    ///@notice This is just a view function to show if the user has enough balance of the materials required.
    function userMaterialsEnough(uint256 equipment_type, uint256 item_count) public view returns (bool enough){
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
        (uint256 main_material_balance, ) = checkMaterialBalance(recipe.main_material);
        (uint256 indirect_material_balance, ) = checkMaterialBalance(recipe.indirect_material);
        (uint256 catalyst_balance, ) = checkCatalystBalance(recipe.catalyst);

        ///We compare the user's token balances with the required amounts.
        if(main_material_balance < recipe.main_material_amount){enough = false;}
        if(indirect_material_balance < recipe.indirect_material_amount){enough = false;}
        if(catalyst_balance < recipe.catalyst_amount){enough = false;}
    }

    ///@notice This function is just an easy way to get the recipe of a certain equipment
    function getEquipmentRecipe(uint256 equipment_type) public pure returns (item_recipe memory recipe){
        recipe = CraftingRecipes.getRecipe(equipment_type);
    }

    ///@notice Admin Functions
    function setRandomizationContract(address _vrfContract) public onlyOwner {
        vrfContract = _vrfContract;
        randomizer = _RandomizationContract(_vrfContract);
    }

    function setMintFee(uint256 amount) public onlyOwner {
        mint_fee = amount * 1 gwei;
    }

    modifier onlyVRF(){
        require(msg.sender == vrfContract, "eMNTR: Can only be called by the VRF Contract for equipment crafting.");
        _;
    }

    function withdraw() public onlyOwner{
        (bool succeed, ) = vrf_refunder.call{value: address(this).balance}("");
        require(succeed, "Failed to withdraw matics.");
    }
}
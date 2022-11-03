// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// KeeperCompatible.sol imports the functions from both ./KeeperBase.sol and
// ./interfaces/KeeperCompatibleInterface.sol
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface Dungeon {
      function replenishDungeonLoot() external;
}

contract DungeonKeeper is KeeperCompatibleInterface, Ownable, Pausable {
    error OnlyKeeperRegistry();

    uint public interval;
    uint public lastTimeStamp;

    address public s_keeperRegistryAddress;

    Dungeon dungeon;

    constructor(address _dungeonAddress, address _keepersRegistry) {
      interval = 10800; //trigger every 3 hours
      lastTimeStamp = block.timestamp;
      dungeon = Dungeon(_dungeonAddress);
      setKeeperRegistryAddress(_keepersRegistry);
    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
    }

    function performUpkeep(bytes calldata /* performData */) external override onlyKeeperRegistry{
        //Revalidate the upkeep
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;
            dungeon.replenishDungeonLoot();   
        }
    }

    function setInterval(uint _newInterval) external onlyOwner{
        interval = _newInterval;
    }

    /**
   * @notice Sets the keeper registry address
   */
    function setKeeperRegistryAddress(address keeperRegistryAddress) public onlyOwner {
        require(keeperRegistryAddress != address(0));
        s_keeperRegistryAddress = keeperRegistryAddress;
    }

      /**
   * @notice Pauses the contract, which prevents executing performUpkeep
   */
    function pause() external onlyOwner {
        _pause();
    }

    /**
    * @notice Unpauses the contract
    */
    function unpause() external onlyOwner {
        _unpause();
    }

    modifier onlyKeeperRegistry() {
        if (msg.sender != s_keeperRegistryAddress) {
        revert OnlyKeeperRegistry();
        }
        _;
    }
}


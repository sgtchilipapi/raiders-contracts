// SPDX-License-Identifier: MIT
/**
    @title Characters
    @author Eman "Sgt"
    @notice: NFT Contract for playable characters.
    Originally created for CHAINLINK HACKATHON FALL 2022
*/
pragma solidity =0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/Counters.sol";
import "../utils/BreakdownUint256.sol";
import "../libraries/characters/CharacterLibrary.sol";
import "../libraries/StructLibrary.sol";
interface _RandomizationContract {
    function requestRandomWords(uint32 numWords) external returns (uint256 s_requestId);
    function randomNumber(uint256) external view returns(uint256[] memory);
}

contract Characters is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private character_ids;

    ///Map out a specific character NFT id to its properties {character_class, element, str, vit, dex, mood, exp}
    mapping (uint256 => character_properties) public character;

    ///The address for the minter router
    address private character_minter;

    event CharacterMinted(uint256 indexed character_id, character_properties character_props);

    constructor() ERC721("Characters", "CTRS") {
    }

    function _mintCharacter(address user, character_properties memory character_props) public onlyMinter{
        character_ids.increment();
        character[character_ids.current()] = character_props;
        _mint(user, character_ids.current());
        emit CharacterMinted(character_ids.current(), character[character_ids.current()]);
    }    

    ///@notice This function sets the minter contract.
    function setMinter(address minterAddress) public onlyOwner{
        character_minter = minterAddress;
    }

    ///@notice Custom modifier to only allow the minter for some functions.
    modifier onlyMinter(){
        require(msg.sender == character_minter,"CTRS: Can only be called by the Router Minter.");
        _;
    }

    ///@notice We expose a pubic `isOwner` for use in our other contracts.
    function isOwner(address _owner, uint256 _character) public view returns (bool){
        return super._isApprovedOrOwner(_owner, _character);
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
}
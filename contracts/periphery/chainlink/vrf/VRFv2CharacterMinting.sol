// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import '@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol';
import '@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';

interface Minter {
    function mintCharacterExperimental(address user, uint256[] memory randomNumberRequested) external;
}

contract VRFv2CharacterMinting is VRFConsumerBaseV2, ConfirmedOwner {
    event RequestSent(uint256 requestId, uint32 numWords, address user, bool experimental);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords, address user, bool experimental);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
        bool experimental; //whether the contract is going to mint the NFT upon fulfillment
    }
    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */
    
    mapping(uint256 => address) public requestIdToUser;

    VRFCoordinatorV2Interface COORDINATOR;

    ///@notice The minter contract
    Minter minter;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/#configurations
    bytes32 private keyHash;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    constructor(uint64 subscriptionId, address _coordinator, bytes32 _keyHash, address ownerContract)
        VRFConsumerBaseV2(_coordinator) ConfirmedOwner(ownerContract)
    {
        COORDINATOR = VRFCoordinatorV2Interface(_coordinator);
        keyHash = _keyHash;
        s_subscriptionId = subscriptionId;
        minter = Minter(ownerContract);
    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords(address user, bool _experimental)external onlyOwner returns (uint256 requestId) {
        ///Will revert if subscription is not set and funded.
        uint32 callbackGasLimit = 100000;
        uint32 numWords = 1;

        ///@notice if the request being set is experimental, we set the callbackGasLimit higher to a safe level to ensure that
        ///fulfillRandomWords() has enough gas to process the transaction since it will have the responsibility to complete
        ///the mint transaction.
        if(_experimental){
            callbackGasLimit = 100000 + (numWords * 600000);
        }

        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({randomWords: new uint256[](0), exists: true, fulfilled: false, experimental: _experimental});
        requestIds.push(requestId);
        lastRequestId = requestId;
        requestIdToUser[requestId] = user;
        emit RequestSent(requestId, numWords, user, _experimental);
        return requestId;
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(s_requests[_requestId].exists, 'request not found');
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;

        if(s_requests[_requestId].experimental == true){
            ///@notice !!! This is an external call to the minter contract to mint the NFTs for the user.
            minter.mintCharacterExperimental(requestIdToUser[_requestId], _randomWords);
        }
        
        emit RequestFulfilled(_requestId, _randomWords, requestIdToUser[_requestId], s_requests[_requestId].experimental);
    }

    function getRequestStatus(uint256 _requestId) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, 'request not found');
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }
}


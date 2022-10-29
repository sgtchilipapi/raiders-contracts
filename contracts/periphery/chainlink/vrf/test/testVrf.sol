// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import 'hardhat/console.sol';

contract TestVRF {
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

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    constructor(){}

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords(address user, uint32 numWords, bool _experimental)external returns (uint256 requestId) {
        requestId = lastRequestId + 1;
        s_requests[requestId] = RequestStatus({randomWords: new uint256[](0), exists: true, fulfilled: false, experimental: _experimental});
        requestIds.push(requestId);
        lastRequestId = requestId;
        requestIdToUser[requestId] = user;
        emit RequestSent(requestId, numWords, user, _experimental);
        fulfillRandomWords(requestId, generateRandomWords(numWords));
        return requestId;
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal {
        require(s_requests[_requestId].exists, 'request not found');
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords, requestIdToUser[_requestId], s_requests[_requestId].experimental);
    }

    function generateRandomWords(uint32 numWords) internal view returns (uint256[] memory){
        uint[] memory randomWords = new uint[](numWords);
        for(uint256 i = 0; i < numWords; i++){
            uint256 random_num = uint256(keccak256(abi.encodePacked(uint256(blockhash(block.number)), i)));
            randomWords[i] = random_num;
        }
        return randomWords;
    }

    function getRequestStatus(uint256 _requestId) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, 'request not found');
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }
}


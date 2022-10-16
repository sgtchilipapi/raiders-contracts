// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';
import '@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol';

contract VRFv2DirectFundingConsumer is VRFV2WrapperConsumerBase, ConfirmedOwner {
    event RequestSent(uint256 requestId, uint32 numWords, address user);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords, uint256 payment, address user);

    struct RequestStatus {
        uint256 paid; // amount paid in link
        bool fulfilled; // whether the request has been successfully fulfilled
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */
    mapping(uint256 => address) public requestIdToUser;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // Address LINK - hardcoded for Polygon
    address linkAddress = 0xb0897686c545045aFc77CF20eC7A532E3120E0F1;

    // address WRAPPER - hardcoded for Polygon
    address wrapperAddress = 0x4e42f0adEB69203ef7AaA4B7c414e5b1331c14dc;

    ///@notice The only addresse/s that can call `requestRandomWords()`
    address[] whitelistedAddresses;

    constructor() ConfirmedOwner(msg.sender) VRFV2WrapperConsumerBase(linkAddress, wrapperAddress) {}

    ///@notice Adds a new address to the whitelisted Addresses i.e. the addresses that can request random words.
    ///Can only be called by the owner.
    function addToWhitelistedAddresses(address _address) public onlyOwner {
        whitelistedAddresses.push(_address);
    }

    ///@notice This is a custom modifier that does a check on all the whitelisted address in an array. This will result to additional
    ///but minimal gas spending as it will loop thru a number of whitelisted address.
    modifier onlyWhitelisted(){
        for(uint256 i = 0; i < whitelistedAddresses.length; i++){
            ///If there is a match, stop the loop and jump back to the requestRandomWords() for continuation.
            if(msg.sender == whitelistedAddresses[i]){
                _;
            }
        }
        ///If loop ends without a match, it means the caller is not whitelisted.
        revert("VRF: Address is not allowed to submit requests.");
    }

    ///@notice This removes an item in the whitelisted addresses in case such contract with the address gets obsolete.
    ///Can only be called by the owner.
    function removeWhitelistedAddress(uint256 index) public onlyOwner {
        require(whitelistedAddresses.length > index, "Out of bounds");
        // move all elements to the left, starting from the `index + 1`
        for (uint256 i = index; i < whitelistedAddresses.length - 1; i++) {
            whitelistedAddresses[i] = whitelistedAddresses[i+1];
        }
        whitelistedAddresses.pop(); // delete the last item
    }

    function requestRandomWords(uint32 numWords, address user) external onlyWhitelisted returns (uint256 requestId) {
        uint32 callbackGasLimit = 100000 + (numWords * 25000);
        requestId = requestRandomness(callbackGasLimit, requestConfirmations, numWords);
        s_requests[requestId] = RequestStatus({
            paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWords: new uint256[](0),
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        requestIdToUser[requestId] = user;
        emit RequestSent(requestId, numWords, user);
        return requestId;
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(s_requests[_requestId].paid > 0, 'request not found');
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        ///@notice Added user address to easily filter out events when our front-end is listening to requests being fulfilled.
        emit RequestFulfilled(_requestId, _randomWords, s_requests[_requestId].paid, requestIdToUser[_requestId]);
    }

    function getRequestStatus(uint256 _requestId)
        external
        view
        returns (
            uint256 paid,
            bool fulfilled,
            uint256[] memory randomWords
        )
    {
        require(s_requests[_requestId].paid > 0, 'request not found');
        RequestStatus memory request = s_requests[_requestId];
        return (request.paid, request.fulfilled, request.randomWords);
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(linkAddress);
        require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    }
}

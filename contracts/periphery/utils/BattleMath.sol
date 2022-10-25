//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library BattleMath {
    function safeMinusUint256(uint256 subtrahend, uint256 subtractor)
        internal
        pure
        returns (uint256 diff)
    {
        diff = (subtractor > subtrahend) ? 0 : (subtrahend - subtractor);
    }

    function safeAddUint256(
        uint256 addend1,
        uint256 addend2,
        uint256 max
    ) internal pure returns (uint256 sum) {
        sum = (addend1 + addend2) > max ? max : addend1 + addend2;
    }
}
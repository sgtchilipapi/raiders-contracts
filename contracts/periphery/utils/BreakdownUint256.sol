//SPDX-License-Identifier: MIT
///@author https://ethereum.stackexchange.com/users/102976/jeremy-then
///@notice This is a modified code snippet from his stack overflow answer here: https://ethereum.stackexchange.com/a/133983

pragma solidity ^0.8.7;

library BreakdownUint256 {
    function break256BitsIntegerIntoBytesArrayOf8Bits(uint256 n) internal pure returns(uint8[] memory) {

        uint8[] memory _8BitNumbers = new uint8[](32);

        uint256 mask = 0x00000000000000000000000000000000000000000000000000000000000000ff;
        uint256 shiftBy = 0;

        for(int256 i = 31; i >= 0; i--) { 
            uint256 v = n & mask;
            mask <<= 8;
            v >>= shiftBy;
            _8BitNumbers[uint(i)] = uint8(v);
            shiftBy += 8;
        }
        return _8BitNumbers;
    }

    function break256BitsIntegerIntoBytesArrayOf16Bits(uint256 n) internal pure returns(uint16[] memory) {

        uint16[] memory _16BitNumbers = new uint16[](16);

        uint256 mask = 0x000000000000000000000000000000000000000000000000000000000000ffff;
        uint256 shiftBy = 0;

        for(int256 i = 15; i >= 0; i--) { 
            uint256 v = n & mask;
            mask <<= 16;
            v >>= shiftBy;
            _16BitNumbers[uint(i)] = uint16(v);
            shiftBy += 16;
        }
        return _16BitNumbers;
    }

    function break256BitsIntegerIntoBytesArrayOf32Bits(uint256 n) internal pure returns(uint32[] memory) {

        uint32[] memory _32BitNumbers = new uint32[](8);

        uint256 mask = 0x00000000000000000000000000000000000000000000000000000000ffffffff;
        uint256 shiftBy = 0;

        for(int256 i = 7; i >= 0; i--) { 
            uint256 v = n & mask;
            mask <<= 32;
            v >>= shiftBy;
            _32BitNumbers[uint(i)] = uint32(v);
            shiftBy += 32;
        }
        return _32BitNumbers;
    }
}


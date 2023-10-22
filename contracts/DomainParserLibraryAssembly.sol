// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;
import "hardhat/console.sol";


library DomainString {
    function split(string memory _domain)
        public
        pure
        returns (string[] memory)
    {
        _domain = removeProtocol(_domain);
        bytes memory domainBytes = bytes(_domain);

        uint256 count;
        string[] memory result;
        uint256 lastSplit;
        uint256 j;

        assembly {
            let domainLength := mload(domainBytes)
            count := 0

            // Підрахунок кількості розділювачів "."
            for {
                let i := 0
            } lt(i, domainLength) {
                i := add(i, 1)
            } {
                let byteValue := and(mload(add(add(domainBytes, 0x20), i)), 0xFF)

                if eq(byteValue, 46) {  // 46 is ASCII for "."
                    count := add(count, 1)
                }
                /*if eq(mload(add(add(domainBytes, 0x20), i)), 46) {
                    // 46 is ASCII for "."
                    count := add(count, 1)
                }*/
            }

            // Виділіть пам'ять для масиву рядків
            result := mload(0x40)
            mstore(0x40, add(result, add(0x20, mul(count, 0x20))))
            mstore(result, count)

            j := 0
            lastSplit := 0

            for {
                let i := 0
            } lt(i, domainLength) {
                i := add(i, 1)
            } {
                // Якщо ми знайшли розділювач або це останній байт домену
                if or(
                    eq(mload(add(add(domainBytes, 1), i)), 46),
                    eq(i, sub(domainLength, 1))
                ) {
                    let partLength := sub(i, lastSplit)
                    let part := mload(0x40)
                    mstore(0x40, add(part, add(0x20, partLength)))
                    mstore(part, partLength)

                    for {
                        let k := 0
                    } lt(k, partLength) {
                        k := add(k, 1)
                    } {
                        let b := mload(
                            add(add(add(domainBytes, 1), lastSplit), k)
                        )
                        mstore(add(add(part, 1), k), b)
                    }

                    mstore(add(result, add(0x20, mul(j, 0x20))), part)
                    lastSplit := add(i, 1)
                    j := add(j, 1)
                }
            }
        }

      /*if (count == 0) {
            revert("Invalid domain format");
        }*/

        return result;
    }

    function removeProtocol(string memory _domain)
        public
        pure
        returns (string memory)
    {
        console.log(startsWith(_domain, "https://"));
        if (startsWith(_domain, "https://")) {
            return substring(_domain, 8, bytes(_domain).length);
        }

        return _domain;
    }

    function substring(
        string memory str,
        uint256 startIndex,
        uint256 endIndex
    ) private pure returns (string memory) {
        require(endIndex >= startIndex, "Invalid indexes");

        bytes memory result;

        assembly {
            let strLength := mload(str)

            if or(gt(startIndex, strLength), gt(endIndex, strLength)) {
                revert(0, 0)
            }

            let resultLength := sub(endIndex, startIndex)

            result := mload(0x40)
            mstore(result, resultLength)

            for {
                let i := 0
            } lt(i, resultLength) {
                i := add(i, 1)
            } {
                let b := mload(add(add(str, 32), add(startIndex, i)))
                mstore(add(add(result, 32), i), b)
            }

            mstore(0x40, add(add(result, 32), resultLength))
        }

        return string(result);
    }

    function startsWith(string memory _string, string memory _prefix)
        private
        pure
        returns (bool)
    {
        bytes memory stringBytes = bytes(_string);
        bytes memory prefixBytes = bytes(_prefix);

        bool result = false;

        assembly {
            let stringLength := mload(stringBytes)
            let prefixLength := mload(prefixBytes)

            if gt(prefixLength, stringLength) {
                result := 0
            }

            for {
                let i := 0
            } lt(i, prefixLength) {
                i := add(i, 1)
            } {
                let stringChar := mload(add(add(stringBytes, 32), i))
                let prefixChar := mload(add(add(prefixBytes, 32), i))

                switch eq(stringChar, prefixChar)
                case 0 {
                    result := 0
                    i := prefixLength
                }
                default {
                    result := 1
                }
            }
        }

        return result;
    }
}

library DomainJoin {
    function join(string[] memory parts) public pure returns (string memory) {
        if (parts.length == 0) {
            return "";
        }

        uint256 totalLength = 0;
        for (uint256 i = 0; i < parts.length; i++) {
            totalLength += bytes(parts[i]).length;
        }
        totalLength += parts.length - 1;

        string memory result = new string(totalLength);
        uint256 resultPos;

        assembly {
            resultPos := add(result, 0x20)

            let partsLength := mload(parts)
            for {
                let i := 0
            } lt(i, partsLength) {
                i := add(i, 1)
            } {
                let part := mload(add(add(parts, 0x20), mul(i, 0x20)))
                let partLength := mload(part)

                for {
                    let j := 0
                } lt(j, partLength) {
                    j := add(j, 1)
                } {
                    mstore8(resultPos, mload(add(add(part, 0x20), j)))
                    resultPos := add(resultPos, 1)
                }

                if lt(i, sub(partsLength, 1)) {
                    mstore8(resultPos, 46) // ASCII code for "."
                    resultPos := add(resultPos, 1)
                }
            }
        }

        return result;
    }
}

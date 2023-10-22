// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

library DomainString {
    function split(
        string memory _domain
    ) public pure returns (string[] memory) {
        _domain = removeProtocol(_domain);

        bytes memory domainBytes = bytes(_domain);
        uint256 count = 1;
        for (uint256 i = 0; i < domainBytes.length; i++) {
            if (domainBytes[i] == ".") {
                count++;
            }
        }

        string[] memory result = new string[](count);
        uint256 j = 0;
        uint256 lastSplit = 0;
        for (uint256 i = 0; i < domainBytes.length; i++) {
            if (domainBytes[i] == ".") {
                bytes memory part = new bytes(i - lastSplit);
                for (uint256 k = 0; k < part.length; k++) {
                    part[k] = domainBytes[lastSplit + k];
                }
                result[j] = string(part);
                lastSplit = i + 1;
                j++;
            }
            if (i == domainBytes.length - 1) {
                bytes memory part = new bytes(domainBytes.length - lastSplit);
                for (uint256 k = 0; k < part.length; k++) {
                    part[k] = domainBytes[lastSplit + k];
                }
                result[j] = string(part);
            }
        }

        if (result.length == 1) {
            revert("Invalid domain format");
        }

        return result;
    }

    function removeProtocol(
        string memory _domain
    ) public pure returns (string memory) {
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
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = 0; i < endIndex - startIndex; i++) {
            result[i] = strBytes[i + startIndex];
        }
        return string(result);
    }

    function startsWith(
        string memory _string,
        string memory _prefix
    ) private pure returns (bool) {
        bytes memory stringBytes = bytes(_string);
        bytes memory prefixBytes = bytes(_prefix);

        if (prefixBytes.length > stringBytes.length) {
            return false;
        }

        for (uint256 i = 0; i < prefixBytes.length; i++) {
            if (stringBytes[i] != prefixBytes[i]) {
                return false;
            }
        }
        return true;
    }
}

library DomainJoin {
    function join(string[] memory parts) public pure returns (string memory) {
        string memory result = parts[0];
        for (uint256 i = 1; i < parts.length; i++) {
            result = string(abi.encodePacked(result, ".", parts[i]));
        }
        return result;
    }
}

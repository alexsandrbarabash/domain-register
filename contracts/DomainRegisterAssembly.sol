// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {DomainJoin, DomainString} from "./DomainParserLibraryAssembly.sol";
import "hardhat/console.sol";

contract DomainRegister {
    uint256 public immutable minimalPledge;

    using DomainString for string;
    using DomainJoin for string[];

    mapping(string => Domain) public register;

    struct Domain {
        address owner;
        uint256 pledge;
    }

    constructor(uint256 _minimalPledge) {
        minimalPledge = _minimalPledge;
    }

    modifier onlyNewDomain(string memory _domain) {
        require(register[_domain].pledge == 0, "Domain is already taken.");
        _;
    }

    modifier onlyDomainOwner(string memory _domain) {
        console.log(
        "DOmain owner %s",
        register[_domain].owner
        );
        require(
            register[_domain].owner == msg.sender,
            "You must own the domain to release it."
        );
        _;
    }

    modifier checkFatherDomain(string memory _domain) {
        string[] memory splitDomain = DomainString.split(_domain);

        if (splitDomain.length > 2) {
            string[] memory fatherDomainSplit = new string[](
                splitDomain.length - 1
            );
            for (uint256 i = 0; i < splitDomain.length - 1; i++) {
                fatherDomainSplit[i] = splitDomain[i + 1];
            }
            string memory fatherDomain = DomainJoin.join(fatherDomainSplit);
            require(
                register[fatherDomain].owner == msg.sender,
                "Father domain must exist & you must own it."
            );
        }
        _;
    }

    modifier onlyWithValue() {
        require(
            msg.value >= minimalPledge,
            "Must send enough amount of ether to register a domain."
        );
        _;
    }

    function registerDomain(
        string memory _domain
    )
        public
        payable
        onlyWithValue
        onlyNewDomain(_domain)
        checkFatherDomain(_domain)
    {
        _domain = _domain.removeProtocol();
        console.log("Domain %s", _domain);
        register[_domain].owner = msg.sender;
        register[_domain].pledge = msg.value;
    }

    function releaseDomain(
        string memory _domain
    ) public onlyDomainOwner(_domain) {
        payable(msg.sender).transfer(register[_domain].pledge);

        delete register[_domain];
    }
}

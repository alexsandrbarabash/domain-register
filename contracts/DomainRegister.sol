// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

contract DomainRegister {
    uint256 public immutable minimalPledge;

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
        require(
            register[_domain].owner == msg.sender,
            "You must own the domain to release it."
        );
        _;
    }

    modifier onlyWithValue() {
        require(
            msg.value >= minimalPledge,
            "Must send enough amount of ether to register a domain."
        );
        _;
    }

    function registerDomain(string memory _domain)
        public
        payable
        onlyWithValue
        onlyNewDomain(_domain)
    {
        register[_domain].owner = msg.sender;
        register[_domain].pledge = msg.value;
    }

    function releaseDomain(string memory _domain)
        public
        onlyDomainOwner(_domain)
    {
        payable(msg.sender).transfer(register[_domain].pledge);

        delete register[_domain];
    }
}

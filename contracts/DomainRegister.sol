// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

contract DomainRegister {
    uint public  minimalPledge;

    mapping (string => address) public register;
    mapping (string => uint) domainPledge;
    mapping (address => string[]) userDomains;
    
    constructor(uint _minimalPledge) {
        minimalPledge = _minimalPl  edge;
    }

    modifier onlyNewDomain(string memory _domain) {
        require(register[_domain] == address(0), "Domain is already taken.");
        _;
    }
    
    modifier onlyDomainOwner(string memory _domain) {
        require(register[_domain] == msg.sender, "You must own the domain to release it.");
        _;
    }
    
    modifier onlyWithValue() {
        require(msg.value >= minimalPledge, "Must send enough amount of ether to register a domain.");
        _;
    }

    function registerDomain(string memory _domain) public payable onlyWithValue onlyNewDomain(_domain) {
        register[_domain] = msg.sender;
        domainPledge[_domain] = msg.value;
        userDomains[msg.sender].push(_domain);
    }

    function releaseDomain(string memory _domain) 
        public 
        onlyDomainOwner(_domain)
    {
        payable(msg.sender).transfer(domainPledge[_domain]);

        string[] storage domains = userDomains[msg.sender];
        for(uint i = 0; i < domains.length; i++) {
            if(keccak256(bytes(domains[i])) == keccak256(bytes(_domain))) {
                domains[i] = domains[domains.length - 1];
                domains.pop();
                break;
            }
        }

        delete register[_domain];
        delete domainPledge[_domain];
    }

    function getUserDomains(address userAddress) public view returns (string[] memory) {
        return userDomains[userAddress];
    }

    function getMyDomains() public view returns (string[] memory) {
        return userDomains[msg.sender];
    }

}

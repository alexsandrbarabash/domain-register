import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract } from "ethers";

describe("DomainRegister", function () {
  let DomainRegister: Contract;
  let domainRegister: Contract;
  let owner: Contract;
  let addr1: Contract;
  let addr2: Contract;

  beforeEach(async function () {
    const DomainJoinLibrary = await ethers.getContractFactory("DomainJoin");

    const domainJoinLibrary = await DomainJoinLibrary.deploy();
    await domainJoinLibrary.waitForDeployment();

    const DomainSplitLibrary = await ethers.getContractFactory("DomainSplit");
    const domainSplitLibrary = await DomainSplitLibrary.deploy();
    await domainSplitLibrary.waitForDeployment();

    DomainRegister = await ethers.getContractFactory("DomainRegister", {
      libraries: {
        DomainJoin: domainJoinLibrary.target,
        DomainSplit: domainSplitLibrary.target,
      },
    });
    [owner, addr1, addr2] = await ethers.getSigners();
    domainRegister = await DomainRegister.deploy(ethers.parseEther("1"));
    // await domainRegister.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the right minimalPledge", async function () {
      expect(await domainRegister.minimalPledge()).to.equal(
        ethers.parseEther("1")
      );
    });
  });

  describe("Domain registration", function () {
    it("Should register domain and reflect in user domains", async function () {
      const value = ethers.parseEther("1");
      await domainRegister
        .connect(addr1)
        .registerDomain("example.com", { value: ethers.parseEther("1") });

      const domain = await domainRegister.register("example.com");
      expect(domain.owner).to.equal(addr1.address);
      expect(domain.pledge.toString()).to.equal(
        ethers.parseEther("1").toString()
      );
    });

    it("Should fail if domain already exists", async function () {
      await domainRegister
        .connect(addr1)
        .registerDomain("com", { value: ethers.parseEther("1") });
      await expect(
        domainRegister
          .connect(addr2)
          .registerDomain("example.com", { value: ethers.parseEther("1") })
      ).to.be.revertedWith("Domain is already taken.");
    });

    it("Should fail if not enough ether is sent", async function () {
      await expect(
        domainRegister
          .connect(addr1)
          .registerDomain("example.com", { value: ethers.parseEther("0.5") })
      ).to.be.revertedWith(
        "Must send enough amount of ether to register a domain."
      );
    });
  });

  describe("Domain release", function () {
    it("Should release domain and reflect in user domains", async function () {
      await domainRegister
        .connect(addr1)
        .registerDomain("example.com", { value: ethers.parseEther("1") });
      await domainRegister.connect(addr1).releaseDomain("example.com");

      const domain = await domainRegister.register("example.com");

      expect(domain.owner).to.equal(ethers.ZeroAddress);
    });

    it("Should not allow non-owner to release a domain", async function () {
      await domainRegister.connect(addr1).registerDomain("example.com", {
        value: ethers.parseEther("1"),
      });

      await expect(
        domainRegister.connect(addr2).releaseDomain("example.com")
      ).to.be.revertedWith("You must own the domain to release it.");
    });
  });
});

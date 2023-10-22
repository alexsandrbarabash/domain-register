import { ethers } from "hardhat";

async function main() {
  const minimalPledge = ethers.parseEther("1");

  const DomainJoinLibrary = await ethers.getContractFactory("DomainJoin");

  const domainJoinLibrary = await DomainJoinLibrary.deploy();
  await domainJoinLibrary.waitForDeployment();

  const DomainSplitLibrary = await ethers.getContractFactory("DomainSplit");
  const domainSplitLibrary = await DomainSplitLibrary.deploy();
  await domainSplitLibrary.waitForDeployment();

  const DomainRegisterFactory = await ethers.getContractFactory(
    "DomainRegister",
    {
      libraries: {
        DomainJoin: domainJoinLibrary.target,
        DomainSplit: domainSplitLibrary.target,
      },
    }
  );
  const domainRegister = await DomainRegisterFactory.deploy(minimalPledge, {});
  await domainRegister.waitForDeployment();

  console.log("DomainRegister deployed to:", domainRegister.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

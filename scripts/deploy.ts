import { ethers } from "hardhat";

async function main() {
  const minimalPledge = ethers.parseEther("1");

  const DomainRegisterFactory = await ethers.getContractFactory(
    "DomainRegister"
  );
  const domainRegister = await DomainRegisterFactory.deploy(minimalPledge);
  await domainRegister.waitForDeployment();

  console.log("DomainRegister deployed to:", domainRegister.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

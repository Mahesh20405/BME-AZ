const hre = require("hardhat");

async function main() {
  // Get the contract factory
  const Migrations = await hre.ethers.getContractFactory("Migrations");

  // Deploy contract
  const migrations = await Migrations.deploy();

  // Wait for deployment
  await migrations.deployed();

  console.log("Migrations contract deployed to:", migrations.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

const hre = require("hardhat");

async function main() {
  // Get the contract factory
  const Migrations = await hre.ethers.getContractFactory("Migrations");

  // Deploy contract
  const migrations = await Migrations.deploy();

  // Wait for deployment to complete
  await migrations.waitForDeployment(); // ✅ Corrected from `.deployed()`

  console.log("Migrations contract deployed to:", await migrations.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

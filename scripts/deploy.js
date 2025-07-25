// scripts/deploy.js
// Hardhat deployment script for Lock, SimpleERC20, and ERC1967Proxy

const hre = require("hardhat");

const { FireblocksWeb3Provider, ChainId, ApiBaseUrl } = require("@fireblocks/fireblocks-web3-provider")
const Web3 = require("web3");

const eip1193Provider = new FireblocksWeb3Provider({
    privateKey: process.env.FIREBLOCKS_API_PRIVATE_KEY_PATH,
    apiKey: process.env.FIREBLOCKS_API_KEY,
    vaultAccountIds: process.env.FIREBLOCKS_VAULT_ACCOUNT_IDS,
    chainId: ChainId.SEPOLIA,
 // apiBaseUrl: ApiBaseUrl.Sandbox // If using a sandbox workspace
});

const web3 = new Web3(eip1193Provider);

async function main() {
  // Deploy Lock
  const unlockTime = Math.floor(Date.now() / 1000) + 60 * 60; // 1 hour from now
  const Lock = await hre.ethers.getContractFactory("Lock");
  const lock = await Lock.deploy(unlockTime, { value: hre.ethers.parseEther("0.1") });
  await lock.waitForDeployment();
  console.log("Lock deployed to:", await lock.getAddress());

  // Deploy SimpleERC20
  const initialSupply = hre.ethers.parseUnits("1000", 18);
  const SimpleERC20 = await hre.ethers.getContractFactory("SimpleERC20");
  const erc20 = await SimpleERC20.deploy(initialSupply);
  await erc20.waitForDeployment();
  console.log("SimpleERC20 deployed to:", await erc20.getAddress());

  // Deploy ERC1967Proxy with SimpleERC20 as logic contract
  const ERC1967Proxy = await hre.ethers.getContractFactory("ERC1967Proxy");
  const data = "0x"; // No initialization data
  const proxy = await ERC1967Proxy.deploy(await erc20.getAddress(), data);
  await proxy.waitForDeployment();
  console.log("ERC1967Proxy deployed to:", await proxy.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

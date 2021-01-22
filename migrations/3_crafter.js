// ============ Contracts ============

const DecentracraftWorld = artifacts.require("DecentracraftWorld");

const EPDebtNFT = artifacts.require("EPDebtNFT");
const EPDebtCrafter = artifacts.require("EPDebtCrafter");

// ============ Main Migration ============

const migration = async (deployer, network, accounts) => {
  await Promise.all([
    await deployNFTCrafter(deployer, network, accounts),
  ]);
}

module.exports = migration;

// ============ Deploy Functions ============

async function deployNFTCrafter(deployer, network, accounts) {
  console.log(network)
  let dccworld = await DecentracraftWorld.deployed();
  let dccworldaddress = await dccworld.address;
  let nft = await EPDebtNFT.deployed();
  

  try {    
    let old_crafter = await EPDebtCrafter.deployed();
    console.log("Removing old crafter : " + old_crafter.address);
    await dccworld.removeTokenCrafter(old_crafter.address, accounts[0]);    
  } catch (error) {
    console.log("Couldn't Remove old crafter : " + error);    
  }

  await deployer.deploy(EPDebtCrafter, nft.address);

  let crafter = await EPDebtCrafter.deployed();
  
  await nft.setCrafter(crafter.address);
  await nft.setOwner(dccworldaddress);
  await crafter.setOwner(dccworldaddress);

  console.log("Adding new crafter to dcc world : " + dccworld.address);
  console.log("New crafter address : " + crafter.address);
  console.log("New nft address : " + nft.address);
  await dccworld.addTokenCrafter(crafter.address, nft.address, "0x0000000000000000000000000000000000000000"/* rng.address */);
}

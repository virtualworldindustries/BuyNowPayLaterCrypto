// ============ Contracts ============

// Token
// deployed first
const EPDebtNFT = artifacts.require("EPDebtNFT");

// ============ Main Migration ============

const migration = async (deployer, network, accounts) => {
  await Promise.all([
    deployToken(deployer, network, accounts),
  ]);
};

module.exports = migration;

// ============ Deploy Functions ============


async function deployToken(deployer, network, accounts) {

  // let oldnft = await EPDebtNFT.deployed();
  await deployer.deploy(EPDebtNFT);
  let epdebtnft = await EPDebtNFT.deployed();
}

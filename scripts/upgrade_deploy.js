/* eslint-disable import/no-extraneous-dependencies */
const { ethers, upgrades } = require('hardhat');

const BOX_ADDRESS = '0x0309ce5D68Ef02c11889Bb7cf2f5fec9c5Ea412E';

async function main() {
    const UpgradeMarketplace = await ethers.getContractFactory('UpgradeMarketplace');
    const upgradeMarketplace = await upgrades.upgradeProxy(BOX_ADDRESS, UpgradeMarketplace);

    console.log('upgradeMarketplace upgraded: ', upgradeMarketplace.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

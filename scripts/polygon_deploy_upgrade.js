/* eslint-disable import/no-extraneous-dependencies */
const { ethers, upgrades } = require('hardhat');

const BOX_ADDRESS = '0x10Ce249403AD9293395aaAdb834ffC201ebeAb87';

async function main() {
    const UpgradeKlaytn = await ethers.getContractFactory('KlaytnKIP37Modify');
    const upgradeKlaytn = await upgrades.upgradeProxy(BOX_ADDRESS, UpgradeKlaytn);

    console.log('upgradeKlaytn upgraded: ', upgradeKlaytn.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

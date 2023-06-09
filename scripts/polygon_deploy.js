/* eslint-disable import/no-extraneous-dependencies */
const { ethers, upgrades } = require('hardhat');

async function main() {
    const KlaytnKIP37 = await ethers.getContractFactory('KlaytnKIP37Modify');
    const klaytnKIP37 = await upgrades.deployProxy(KlaytnKIP37, []);

    await klaytnKIP37.deployed();

    console.log('KlaytnKIP37 deployed to:', klaytnKIP37.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

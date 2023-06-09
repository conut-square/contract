/* eslint-disable import/no-extraneous-dependencies */
const { ethers } = require('hardhat');

async function main() {
    const KlaytnKIP17 = await ethers.getContractFactory('KlaytnKIP17');
    const klaytnKIP17 = await KlaytnKIP17.deploy();

    await klaytnKIP17.deployed();

    console.log('klaytnKIP17 deployed to:', klaytnKIP17.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

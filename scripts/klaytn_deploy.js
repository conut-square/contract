const hardhat = require('hardhat');
const Caver = require('caver-js');
const KlaytnKIP37 = require('../abi/KlaytnKIP37.json');

async function main() {
    const network = hardhat.config.networks[process.env.REACT_APP_NETWORK];

    console.log(network);

    const caver = new Caver(new Caver.providers.HttpProvider(network.url, {
        headers: [
            { name: 'Authorization', value: `Basic ${Buffer.from(`${process.env.REACT_APP_KAS_ACCESS_ID}:${process.env.REACT_APP_KAS_SECRET_KEY}`).toString('base64')}` },
            { name: 'x-chain-id', value: network.chainId.toString() },
        ],
    }));

    caver.klay.accounts.wallet.add(caver.klay.accounts.privateKeyToAccount(process.env.REACT_APP_FEE_PRIVATE_KEY));

    const transaction = await caver.klay.sendTransaction({
        type: 'SMART_CONTRACT_DEPLOY',
        from: '0xA5e038308B9431cB84CAA35aB46e12C897D8461D',
        data: KlaytnKIP37.bytecode, /* bytecode */
        gas: '50000000',
        value: 0,
    });

    console.log(transaction);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

/* eslint-disable import/no-extraneous-dependencies */
require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-etherscan');
require('@openzeppelin/hardhat-upgrades');
const dotenv = require('dotenv');

dotenv.config();

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

module.exports = {
    defaultNetwork: 'cypress',
    solidity: {
        version: '0.8.7',
        settings: {
            optimizer: {
                enabled: true,
                runs: 200,
            },
        },
    },
    networks: {
        hardhat: {
            chainId: 8217,
            allowUnlimitedContractSize: true,
        },
        cypress: {
            url: 'https://node-api.klaytnapi.com/v1/klaytn',
            httpHeaders: {
                Authorization: `Basic ${Buffer.from('KASKHE4OLMOBI8EI7XFMRYU8:13STaWQ2mrnxXLITLj_h5YPeXScsvmigcezm1tXl').toString('base64')}`,
                'x-chain-id': '8217',
            },
            accounts: ['0x34830ed6b61848203e4c2bc07204571b06657857bfdeab7efa5f13ce2636037d'], // add the account that will deploy the contract (private key)
        },
    },
};

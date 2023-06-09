/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable no-undef */
/* test/sample-test.js */
describe('UpgradeMarketplace', () => {
    it('Should create and execute market sales', async () => {
        /* deploy the marketplace */

        const NFTMarketplace = await ethers.getContractFactory('UpgradeMarketplace');

        const nftMarketplace = await NFTMarketplace.deploy();

        await nftMarketplace.deployed();

        const auctionPrice = ethers.utils.parseUnits('0.25', 'ether');
        const createFee = ethers.utils.parseUnits('0.00625', 'ether');
        const serviceFee = ethers.utils.parseUnits('0.0125', 'ether');
        const totalFee = ethers.utils.parseUnits('0.01875', 'ether');

        /* create two tokens */
        await nftMarketplace.Mint('https://www.mytokenlocation.com', auctionPrice);
        await nftMarketplace.Mint('https://www.mytokenlocation2.com', auctionPrice);

        const [_, buyerAddress] = await ethers.getSigners();

        console.log(buyerAddress);

        /* execute sale of token to another user */
        await nftMarketplace.connect(buyerAddress).Order(1, createFee, serviceFee, totalFee, { value: auctionPrice });
        console.log('10');

        /* resell a token */
        await nftMarketplace.connect(buyerAddress).resellToken(1, auctionPrice);
        console.log('11');

        /* query for and return the unsold items */
        items = await nftMarketplace.fetchMarketItems();
        items = await Promise.all(items.map(async (i) => {
            const tokenUri = await nftMarketplace.tokenURI(i.tokenId);
            const item = {
                price: i.price.toString(),
                tokenId: i.tokenId.toString(),
                seller: i.seller,
                owner: i.owner,
                tokenUri,
            };
            return item;
        }));
        console.log('items: ', items);
    });
});
